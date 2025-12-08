"""
Celery tasks for AI Whisperer.
"""

from celery import shared_task
from django.utils import timezone
from django.conf import settings
from datetime import timedelta
import openai
import logging

logger = logging.getLogger(__name__)


@shared_task(bind=True, max_retries=3)
def transcribe_voice_input(self, voice_input_id: str):
    """
    Transcribe voice input using OpenAI Whisper API.
    This is the ONLY external AI API call in the entire system.

    Args:
        voice_input_id: UUID of the VoiceInput instance

    Returns:
        dict: Status and transcribed text
    """
    from .models import VoiceInput, WhisperSession

    try:
        voice_input = VoiceInput.objects.get(id=voice_input_id)
        logger.info(f"Starting transcription for VoiceInput {voice_input_id}")

        # Update status to processing
        voice_input.transcription_status = 'processing'
        voice_input.save(update_fields=['transcription_status'])

        # Ensure we have the OpenAI API key
        if not settings.OPENAI_API_KEY:
            raise ValueError("OpenAI API key not configured")

        # Configure OpenAI client
        client = openai.OpenAI(api_key=settings.OPENAI_API_KEY)

        # Call Whisper API
        with voice_input.audio_file.open('rb') as audio_file:
            response = client.audio.transcriptions.create(
                model="whisper-1",
                file=audio_file,
                language="en",  # Can be made dynamic based on user settings
                response_format="json"
            )

        transcribed_text = response.text.strip()
        logger.info(f"Transcription completed for VoiceInput {voice_input_id}: {transcribed_text[:50]}...")

        # Update voice input
        voice_input.transcribed_text = transcribed_text
        voice_input.transcription_status = 'completed'
        voice_input.transcription_confidence = 1.0  # Whisper doesn't provide confidence
        voice_input.processed_at = timezone.now()
        voice_input.save()

        # Update session variables
        session = voice_input.session
        variables = session.variables_input.copy()
        variables[voice_input.variable_name] = transcribed_text
        session.variables_input = variables

        # Update session status if needed
        if session.status == 'started':
            session.status = 'variables_collecting'

        session.save(update_fields=['variables_input', 'status'])

        logger.info(f"Updated session {session.id} with transcribed variable: {voice_input.variable_name}")

        return {
            'status': 'success',
            'text': transcribed_text,
            'variable': voice_input.variable_name,
            'session_id': str(session.id)
        }

    except VoiceInput.DoesNotExist:
        logger.error(f"VoiceInput {voice_input_id} not found")
        return {
            'status': 'error',
            'error': 'Voice input not found'
        }

    except Exception as exc:
        logger.error(f"Transcription failed for VoiceInput {voice_input_id}: {str(exc)}")

        # Update voice input status
        try:
            voice_input = VoiceInput.objects.get(id=voice_input_id)
            voice_input.transcription_status = 'failed'
            voice_input.error_message = str(exc)
            voice_input.save()
        except:
            pass

        # Retry with exponential backoff
        retry_countdown = 2 ** self.request.retries
        logger.info(f"Retrying transcription in {retry_countdown} seconds (attempt {self.request.retries + 1}/3)")

        raise self.retry(exc=exc, countdown=retry_countdown)


@shared_task
def cleanup_old_audio_files():
    """
    Daily task to remove audio files older than 7 days.
    Helps manage storage costs.
    """
    from .models import VoiceInput

    cutoff_date = timezone.now() - timedelta(days=7)
    logger.info(f"Starting audio file cleanup for files older than {cutoff_date}")

    old_inputs = VoiceInput.objects.filter(
        created_at__lt=cutoff_date,
        audio_file__isnull=False
    )

    deleted_count = 0
    for voice_input in old_inputs:
        try:
            if voice_input.audio_file:
                voice_input.audio_file.delete(save=False)
                deleted_count += 1
        except Exception as e:
            logger.error(f"Failed to delete audio file for VoiceInput {voice_input.id}: {str(e)}")

    logger.info(f"Cleaned up {deleted_count} audio files")

    return {
        'status': 'success',
        'deleted_count': deleted_count,
        'cutoff_date': cutoff_date.isoformat()
    }


@shared_task
def reset_user_session_counts():
    """
    Monthly task to reset user session counts.
    Runs on the first day of each month.
    """
    from .models import User

    logger.info("Starting monthly session count reset")

    users = User.objects.all()
    reset_count = 0

    for user in users:
        user.sessions_used_this_month = 0
        user.sessions_reset_date = timezone.now().date()
        user.save(update_fields=['sessions_used_this_month', 'sessions_reset_date'])
        reset_count += 1

    logger.info(f"Reset session counts for {reset_count} users")

    return {
        'status': 'success',
        'reset_count': reset_count,
        'reset_date': timezone.now().isoformat()
    }


@shared_task
def cleanup_failed_sessions():
    """
    Clean up sessions that have been stuck in processing state for more than 1 hour.
    """
    from .models import WhisperSession

    cutoff_time = timezone.now() - timedelta(hours=1)
    logger.info(f"Cleaning up stuck sessions older than {cutoff_time}")

    stuck_sessions = WhisperSession.objects.filter(
        status__in=['started', 'variables_collecting', 'processing'],
        created_at__lt=cutoff_time
    )

    updated_count = stuck_sessions.update(
        status='failed',
        error_message='Session timeout - exceeded processing time limit'
    )

    logger.info(f"Marked {updated_count} stuck sessions as failed")

    return {
        'status': 'success',
        'updated_count': updated_count,
        'cutoff_time': cutoff_time.isoformat()
    }
