"""
API Views for AI Whisperer.
"""

from rest_framework import viewsets, status, generics
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from django.shortcuts import get_object_or_404
from django.utils import timezone

from core.models import (
    TemplateCategory, PromptTemplate, WhisperSession,
    VoiceInput, PromptHistory
)
from core.services import InterviewEngine
from core.tasks import transcribe_voice_input

from .serializers import (
    UserRegistrationSerializer, UserSerializer,
    TemplateCategorySerializer,
    PromptTemplateListSerializer, PromptTemplateDetailSerializer,
    WhisperSessionListSerializer, WhisperSessionDetailSerializer,
    WhisperSessionCreateSerializer,
    VoiceInputSerializer, VoiceUploadSerializer,
    PromptHistoryListSerializer, PromptHistoryDetailSerializer,
)

import logging

logger = logging.getLogger(__name__)


class UserRegistrationView(generics.CreateAPIView):
    """
    API endpoint for user registration.
    """
    permission_classes = [AllowAny]
    serializer_class = UserRegistrationSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        return Response({
            'user': UserSerializer(user).data,
            'message': 'User created successfully'
        }, status=status.HTTP_201_CREATED)


class UserProfileView(generics.RetrieveUpdateAPIView):
    """
    API endpoint for user profile.
    """
    permission_classes = [IsAuthenticated]
    serializer_class = UserSerializer

    def get_object(self):
        return self.request.user


class TemplateCategoryViewSet(viewsets.ReadOnlyModelViewSet):
    """
    API endpoints for template categories.
    """
    permission_classes = [IsAuthenticated]
    serializer_class = TemplateCategorySerializer
    queryset = TemplateCategory.objects.filter(is_active=True)
    lookup_field = 'slug'


class PromptTemplateViewSet(viewsets.ReadOnlyModelViewSet):
    """
    API endpoints for prompt templates.
    """
    permission_classes = [IsAuthenticated]
    lookup_field = 'slug'

    def get_queryset(self):
        queryset = PromptTemplate.objects.filter(is_active=True)

        # Filter by category
        category_slug = self.request.query_params.get('category', None)
        if category_slug:
            queryset = queryset.filter(category__slug=category_slug)

        # Filter premium templates for free users
        if self.request.user.subscription_tier == 'free':
            queryset = queryset.filter(is_premium=False)

        return queryset

    def get_serializer_class(self):
        if self.action == 'list':
            return PromptTemplateListSerializer
        return PromptTemplateDetailSerializer


class WhisperSessionViewSet(viewsets.ModelViewSet):
    """
    API endpoints for whisper sessions.
    """
    permission_classes = [IsAuthenticated]
    parser_classes = [JSONParser, MultiPartParser, FormParser]

    def get_queryset(self):
        return WhisperSession.objects.filter(user=self.request.user)

    def get_serializer_class(self):
        if self.action == 'create':
            return WhisperSessionCreateSerializer
        elif self.action == 'list':
            return WhisperSessionListSerializer
        return WhisperSessionDetailSerializer

    def create(self, request, *args, **kwargs):
        """Create a new session"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        session = serializer.save()

        logger.info(f"Created session {session.id} for user {request.user.username}")

        # Return detailed session info
        return Response(
            WhisperSessionDetailSerializer(session).data,
            status=status.HTTP_201_CREATED
        )

    @action(detail=True, methods=['post'], url_path='voice')
    def upload_voice(self, request, pk=None):
        """
        Upload voice input for a specific variable.
        """
        session = self.get_object()

        # Validate session status
        if session.status in ['completed', 'failed']:
            return Response({
                'error': 'Cannot add voice input to completed or failed session'
            }, status=status.HTTP_400_BAD_REQUEST)

        # Validate and process upload
        serializer = VoiceUploadSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        variable_name = serializer.validated_data['variable_name']
        audio_file = serializer.validated_data['audio_file']
        audio_duration = serializer.validated_data.get('audio_duration_ms', 0)

        # Check if variable exists in template
        template_vars = [v['name'] for v in session.template.variables_schema]
        if variable_name not in template_vars:
            return Response({
                'error': f'Variable {variable_name} not found in template'
            }, status=status.HTTP_400_BAD_REQUEST)

        # Create voice input record
        voice_input = VoiceInput.objects.create(
            session=session,
            variable_name=variable_name,
            audio_file=audio_file,
            audio_duration_ms=audio_duration,
            transcription_status='pending'
        )

        logger.info(f"Created voice input {voice_input.id} for variable {variable_name}")

        # Trigger transcription task
        task = transcribe_voice_input.delay(str(voice_input.id))
        voice_input.celery_task_id = task.id
        voice_input.save(update_fields=['celery_task_id'])

        logger.info(f"Started transcription task {task.id} for voice input {voice_input.id}")

        return Response(
            VoiceInputSerializer(voice_input).data,
            status=status.HTTP_201_CREATED
        )

    @action(detail=True, methods=['get'], url_path='status')
    def session_status(self, request, pk=None):
        """
        Get current session status including transcription progress.
        """
        session = self.get_object()
        engine = InterviewEngine(session)

        status_data = engine.get_session_status()

        return Response(status_data)

    @action(detail=True, methods=['post'], url_path='generate')
    def generate_prompt(self, request, pk=None):
        """
        Generate the final prompt from collected variables.
        """
        session = self.get_object()

        # Validate session status
        if session.status == 'completed':
            return Response({
                'message': 'Prompt already generated',
                'prompt': session.generated_prompt,
                'history_id': str(session.history_entry.id) if hasattr(session, 'history_entry') else None
            })

        if session.status == 'failed':
            return Response({
                'error': 'Session failed',
                'error_message': session.error_message
            }, status=status.HTTP_400_BAD_REQUEST)

        # Use Interview Engine to generate prompt
        try:
            engine = InterviewEngine(session)

            # Check if ready
            if not engine.is_ready_to_generate():
                missing = engine.get_required_variables()
                return Response({
                    'error': 'Missing required variables',
                    'missing_variables': [v['name'] for v in missing]
                }, status=status.HTTP_400_BAD_REQUEST)

            # Generate prompt
            prompt = engine.generate_prompt()

            logger.info(f"Generated prompt for session {session.id}")

            # Get history entry
            history = session.history_entry

            return Response({
                'session_id': str(session.id),
                'status': 'completed',
                'prompt': prompt,
                'variables_used': session.variables_processed,
                'history_id': str(history.id),
                'metadata': {
                    'estimated_tokens': session.template.estimated_tokens,
                    'best_for': session.template.best_for,
                    'template_name': session.template.name
                }
            })

        except Exception as e:
            logger.error(f"Failed to generate prompt for session {session.id}: {str(e)}")

            session.status = 'failed'
            session.error_message = str(e)
            session.save()

            return Response({
                'error': 'Failed to generate prompt',
                'message': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class PromptHistoryViewSet(viewsets.ReadOnlyModelViewSet):
    """
    API endpoints for prompt history.
    """
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = PromptHistory.objects.filter(user=self.request.user)

        # Filter favorites
        favorites_only = self.request.query_params.get('favorites', None)
        if favorites_only == 'true':
            queryset = queryset.filter(is_favorite=True)

        # Filter by category
        category = self.request.query_params.get('category', None)
        if category:
            queryset = queryset.filter(template_category=category)

        return queryset

    def get_serializer_class(self):
        if self.action == 'list':
            return PromptHistoryListSerializer
        return PromptHistoryDetailSerializer

    @action(detail=True, methods=['post'], url_path='copy')
    def track_copy(self, request, pk=None):
        """
        Track when a prompt is copied.
        """
        history = self.get_object()
        history.copy_count += 1
        history.last_copied_at = timezone.now()
        history.save(update_fields=['copy_count', 'last_copied_at'])

        return Response({
            'message': 'Copy tracked',
            'copy_count': history.copy_count
        })

    @action(detail=True, methods=['patch'], url_path='favorite')
    def toggle_favorite(self, request, pk=None):
        """
        Toggle favorite status.
        """
        history = self.get_object()
        history.is_favorite = not history.is_favorite
        history.save(update_fields=['is_favorite'])

        return Response({
            'message': 'Favorite toggled',
            'is_favorite': history.is_favorite
        })

    @action(detail=False, methods=['get'], url_path='stats')
    def user_stats(self, request):
        """
        Get user's prompt history statistics.
        """
        queryset = self.get_queryset()

        stats = {
            'total_prompts': queryset.count(),
            'favorites': queryset.filter(is_favorite=True).count(),
            'total_copies': sum(h.copy_count for h in queryset),
            'by_category': {}
        }

        # Count by category
        for history in queryset:
            cat = history.template_category
            if cat not in stats['by_category']:
                stats['by_category'][cat] = 0
            stats['by_category'][cat] += 1

        return Response(stats)
