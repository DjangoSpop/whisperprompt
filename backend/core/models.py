"""
Core models for AI Whisperer application.
These models define the database schema for users, templates, sessions, and history.
"""

import uuid
from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils import timezone


class User(AbstractUser):
    """
    Extended user model with subscription and usage tracking.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    phone = models.CharField(max_length=20, blank=True, null=True)

    # Subscription
    SUBSCRIPTION_CHOICES = [
        ('free', 'Free'),
        ('pro', 'Pro'),
    ]
    subscription_tier = models.CharField(
        max_length=20,
        choices=SUBSCRIPTION_CHOICES,
        default='free'
    )

    # Usage tracking
    sessions_used_this_month = models.IntegerField(default=0)
    sessions_reset_date = models.DateField(default=timezone.now)

    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'users'
        verbose_name = 'User'
        verbose_name_plural = 'Users'

    def __str__(self):
        return self.username

    @property
    def can_create_session(self):
        """Check if user can create a new session based on their tier"""
        from django.conf import settings

        limit = (
            settings.PRO_TIER_MONTHLY_SESSIONS
            if self.subscription_tier == 'pro'
            else settings.FREE_TIER_MONTHLY_SESSIONS
        )

        return self.sessions_used_this_month < limit


class TemplateCategory(models.Model):
    """
    Categories for organizing prompt templates.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100)
    slug = models.SlugField(unique=True, max_length=100)
    icon = models.CharField(max_length=50, help_text="Emoji or icon name")
    description = models.TextField(blank=True)
    order = models.IntegerField(default=0, help_text="Display order")

    # Status
    is_active = models.BooleanField(default=True)

    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'template_categories'
        ordering = ['order', 'name']
        verbose_name = 'Template Category'
        verbose_name_plural = 'Template Categories'

    def __str__(self):
        return self.name


class PromptTemplate(models.Model):
    """
    Pre-built prompt templates with variable placeholders.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    # Basic info
    name = models.CharField(max_length=200)
    slug = models.SlugField(unique=True, max_length=200)
    description = models.TextField()
    category = models.ForeignKey(
        TemplateCategory,
        on_delete=models.CASCADE,
        related_name='templates'
    )

    # Template content
    user_prompt_display = models.TextField(
        help_text="What user sees: 'Write an email about {topic}'"
    )
    prompt_template = models.TextField(
        help_text="Full prompt with {{ variable }} placeholders (Jinja2/Django template syntax)"
    )
    variables_schema = models.JSONField(
        default=list,
        help_text="JSON schema defining variables structure"
    )

    # Metadata
    estimated_tokens = models.IntegerField(
        default=100,
        help_text="Estimated output token count"
    )
    best_for = models.JSONField(
        default=list,
        help_text="List of AI models this works best with (e.g., ['ChatGPT', 'Claude'])"
    )
    tags = models.JSONField(
        default=list,
        help_text="Tags for search and filtering"
    )

    # Status and usage
    is_active = models.BooleanField(default=True)
    is_premium = models.BooleanField(default=False)
    usage_count = models.IntegerField(default=0)

    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'prompt_templates'
        ordering = ['-usage_count', 'name']
        verbose_name = 'Prompt Template'
        verbose_name_plural = 'Prompt Templates'
        indexes = [
            models.Index(fields=['slug']),
            models.Index(fields=['category', 'is_active']),
            models.Index(fields=['-usage_count']),
        ]

    def __str__(self):
        return self.name


class WhisperSession(models.Model):
    """
    A single prompt generation session with state tracking.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    # Relationships
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='sessions'
    )
    template = models.ForeignKey(
        PromptTemplate,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='sessions'
    )

    # Session state
    STATUS_CHOICES = [
        ('started', 'Started'),
        ('variables_collecting', 'Collecting Variables'),
        ('processing', 'Processing'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    ]
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='started'
    )

    # Input/Output data
    variables_input = models.JSONField(
        default=dict,
        help_text="Raw voice transcriptions per variable"
    )
    variables_processed = models.JSONField(
        default=dict,
        help_text="Processed/transformed variables ready for template"
    )
    generated_prompt = models.TextField(blank=True)

    # Error tracking
    error_message = models.TextField(blank=True)

    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'whisper_sessions'
        ordering = ['-created_at']
        verbose_name = 'Whisper Session'
        verbose_name_plural = 'Whisper Sessions'
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['status']),
        ]

    def __str__(self):
        return f"Session {self.id} - {self.status}"


class VoiceInput(models.Model):
    """
    Individual voice recordings within a session for specific variables.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    # Relationship
    session = models.ForeignKey(
        WhisperSession,
        on_delete=models.CASCADE,
        related_name='voice_inputs'
    )

    # Variable information
    variable_name = models.CharField(max_length=100)

    # Audio handling
    audio_file = models.FileField(
        upload_to='voice_inputs/%Y/%m/%d/',
        blank=True,
        null=True
    )
    audio_duration_ms = models.IntegerField(default=0)

    # Transcription
    TRANSCRIPTION_STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('processing', 'Processing'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    ]
    transcription_status = models.CharField(
        max_length=20,
        choices=TRANSCRIPTION_STATUS_CHOICES,
        default='pending'
    )
    transcribed_text = models.TextField(blank=True)
    transcription_confidence = models.FloatField(null=True, blank=True)

    # Error tracking
    error_message = models.TextField(blank=True)

    # Celery task tracking
    celery_task_id = models.CharField(max_length=255, blank=True)

    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    processed_at = models.DateTimeField(null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'voice_inputs'
        ordering = ['created_at']
        verbose_name = 'Voice Input'
        verbose_name_plural = 'Voice Inputs'
        indexes = [
            models.Index(fields=['session', 'variable_name']),
            models.Index(fields=['transcription_status']),
        ]

    def __str__(self):
        return f"Voice Input for {self.variable_name} - {self.transcription_status}"


class PromptHistory(models.Model):
    """
    User's history of generated prompts with quick access data.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    # Relationships
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='prompt_history'
    )
    session = models.OneToOneField(
        WhisperSession,
        on_delete=models.CASCADE,
        related_name='history_entry'
    )

    # Denormalized data for quick access
    template_name = models.CharField(max_length=200)
    template_category = models.CharField(max_length=100)
    prompt_preview = models.CharField(
        max_length=200,
        help_text="First 200 chars for list display"
    )
    full_prompt = models.TextField()
    variables_used = models.JSONField(default=dict)

    # User actions
    is_favorite = models.BooleanField(default=False)
    copy_count = models.IntegerField(default=0)
    last_copied_at = models.DateTimeField(null=True, blank=True)

    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'prompt_history'
        ordering = ['-created_at']
        verbose_name = 'Prompt History'
        verbose_name_plural = 'Prompt History'
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['user', 'is_favorite']),
            models.Index(fields=['-created_at']),
        ]

    def __str__(self):
        return f"{self.template_name} - {self.created_at.strftime('%Y-%m-%d')}"
