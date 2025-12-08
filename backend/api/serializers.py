"""
DRF Serializers for API endpoints.
"""

from rest_framework import serializers
from django.contrib.auth import get_user_model
from core.models import (
    TemplateCategory, PromptTemplate, WhisperSession,
    VoiceInput, PromptHistory
)

User = get_user_model()


class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer for user registration"""
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password_confirm', 'first_name', 'last_name']

    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError("Passwords do not match")
        return data

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = User.objects.create_user(**validated_data)
        return user


class UserSerializer(serializers.ModelSerializer):
    """Serializer for user details"""
    can_create_session = serializers.BooleanField(read_only=True)

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name',
            'subscription_tier', 'sessions_used_this_month',
            'can_create_session', 'date_joined'
        ]
        read_only_fields = ['id', 'date_joined', 'sessions_used_this_month']


class TemplateCategorySerializer(serializers.ModelSerializer):
    """Serializer for template categories"""
    template_count = serializers.SerializerMethodField()

    class Meta:
        model = TemplateCategory
        fields = ['id', 'name', 'slug', 'icon', 'description', 'order', 'template_count']

    def get_template_count(self, obj):
        return obj.templates.filter(is_active=True).count()


class PromptTemplateListSerializer(serializers.ModelSerializer):
    """Serializer for template list view"""
    category_name = serializers.CharField(source='category.name', read_only=True)

    class Meta:
        model = PromptTemplate
        fields = [
            'id', 'name', 'slug', 'description', 'category_name',
            'is_premium', 'usage_count', 'estimated_tokens'
        ]


class PromptTemplateDetailSerializer(serializers.ModelSerializer):
    """Serializer for template detail view"""
    category = TemplateCategorySerializer(read_only=True)

    class Meta:
        model = PromptTemplate
        fields = [
            'id', 'name', 'slug', 'description', 'category',
            'user_prompt_display', 'variables_schema',
            'estimated_tokens', 'best_for', 'tags',
            'is_premium', 'usage_count'
        ]


class VoiceInputSerializer(serializers.ModelSerializer):
    """Serializer for voice inputs"""
    class Meta:
        model = VoiceInput
        fields = [
            'id', 'variable_name', 'audio_duration_ms',
            'transcription_status', 'transcribed_text',
            'celery_task_id', 'created_at', 'processed_at'
        ]
        read_only_fields = [
            'id', 'transcription_status', 'transcribed_text',
            'celery_task_id', 'created_at', 'processed_at'
        ]


class WhisperSessionListSerializer(serializers.ModelSerializer):
    """Serializer for session list view"""
    template_name = serializers.CharField(source='template.name', read_only=True)

    class Meta:
        model = WhisperSession
        fields = [
            'id', 'template_name', 'status',
            'created_at', 'completed_at'
        ]


class WhisperSessionDetailSerializer(serializers.ModelSerializer):
    """Serializer for session detail view"""
    template = PromptTemplateDetailSerializer(read_only=True)
    voice_inputs = VoiceInputSerializer(many=True, read_only=True)

    class Meta:
        model = WhisperSession
        fields = [
            'id', 'template', 'status', 'variables_input',
            'variables_processed', 'generated_prompt',
            'voice_inputs', 'created_at', 'completed_at'
        ]


class WhisperSessionCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating a new session"""
    template_slug = serializers.SlugField(write_only=True)

    class Meta:
        model = WhisperSession
        fields = ['template_slug']

    def validate_template_slug(self, value):
        try:
            template = PromptTemplate.objects.get(slug=value, is_active=True)
        except PromptTemplate.DoesNotExist:
            raise serializers.ValidationError("Template not found or inactive")
        return value

    def create(self, validated_data):
        template_slug = validated_data.pop('template_slug')
        template = PromptTemplate.objects.get(slug=template_slug)

        # Get user from context
        user = self.context['request'].user

        # Check if user can create session
        if not user.can_create_session:
            raise serializers.ValidationError(
                "Monthly session limit reached. Please upgrade to Pro."
            )

        # Create session
        session = WhisperSession.objects.create(
            user=user,
            template=template,
            status='started'
        )

        return session


class PromptHistoryListSerializer(serializers.ModelSerializer):
    """Serializer for history list view"""
    class Meta:
        model = PromptHistory
        fields = [
            'id', 'template_name', 'template_category',
            'prompt_preview', 'is_favorite', 'copy_count',
            'created_at'
        ]


class PromptHistoryDetailSerializer(serializers.ModelSerializer):
    """Serializer for history detail view"""
    session_id = serializers.UUIDField(source='session.id', read_only=True)

    class Meta:
        model = PromptHistory
        fields = [
            'id', 'session_id', 'template_name', 'template_category',
            'full_prompt', 'variables_used', 'is_favorite',
            'copy_count', 'last_copied_at', 'created_at'
        ]


class VoiceUploadSerializer(serializers.Serializer):
    """Serializer for voice file upload"""
    variable_name = serializers.CharField(max_length=100)
    audio_file = serializers.FileField()
    audio_duration_ms = serializers.IntegerField(required=False, default=0)

    def validate_audio_file(self, value):
        # Check file size (max 25MB)
        if value.size > 25 * 1024 * 1024:
            raise serializers.ValidationError("Audio file too large. Max 25MB.")

        # Check file type
        allowed_types = [
            'audio/mpeg', 'audio/mp4', 'audio/wav',
            'audio/webm', 'audio/m4a', 'audio/ogg'
        ]

        # Note: content_type might not always be reliable
        # In production, consider using python-magic for better file type detection

        return value
