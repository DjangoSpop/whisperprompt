"""
Celery configuration for AI Whisperer project.
"""

import os
from celery import Celery
from celery.schedules import crontab

# Set the default Django settings module
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ai_whisperer.settings')

app = Celery('ai_whisperer')

# Load configuration from Django settings
app.config_from_object('django.conf:settings', namespace='CELERY')

# Auto-discover tasks in all installed apps
app.autodiscover_tasks()

# Scheduled tasks
app.conf.beat_schedule = {
    'cleanup-audio-files-daily': {
        'task': 'core.tasks.cleanup_old_audio_files',
        'schedule': crontab(hour=3, minute=0),  # 3 AM daily
    },
    'reset-monthly-sessions': {
        'task': 'core.tasks.reset_user_session_counts',
        'schedule': crontab(day_of_month=1, hour=0, minute=0),  # First day of month
    },
}


@app.task(bind=True, ignore_result=True)
def debug_task(self):
    """Debug task for testing Celery setup"""
    print(f'Request: {self.request!r}')
