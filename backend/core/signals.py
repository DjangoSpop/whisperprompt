"""
Signal handlers for core app.
"""

from django.db.models.signals import post_save
from django.dispatch import receiver
from django.utils import timezone
from .models import WhisperSession, PromptHistory


@receiver(post_save, sender=WhisperSession)
def update_user_session_count(sender, instance, created, **kwargs):
    """Increment user's session count when a new session is created"""
    if created:
        user = instance.user
        user.sessions_used_this_month += 1
        user.save(update_fields=['sessions_used_this_month'])


@receiver(post_save, sender=WhisperSession)
def create_history_entry_on_completion(sender, instance, created, **kwargs):
    """
    Automatically create a history entry when a session is completed.
    This is a safety net - normally history is created by the Interview Engine.
    """
    if not created and instance.status == 'completed' and instance.generated_prompt:
        # Check if history entry already exists
        if not hasattr(instance, 'history_entry'):
            PromptHistory.objects.get_or_create(
                user=instance.user,
                session=instance,
                defaults={
                    'template_name': instance.template.name if instance.template else 'Unknown',
                    'template_category': instance.template.category.name if instance.template else 'Unknown',
                    'prompt_preview': instance.generated_prompt[:200],
                    'full_prompt': instance.generated_prompt,
                    'variables_used': instance.variables_processed,
                }
            )
