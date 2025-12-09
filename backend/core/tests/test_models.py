"""
Tests for core models.
"""

import pytest
from django.contrib.auth import get_user_model
from core.models import (
    TemplateCategory, PromptTemplate, WhisperSession,
    VoiceInput, PromptHistory
)

User = get_user_model()


@pytest.mark.django_db
class TestUserModel:
    """Test User model"""

    def test_create_user(self):
        """Test creating a user"""
        user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )

        assert user.username == 'testuser'
        assert user.email == 'test@example.com'
        assert user.subscription_tier == 'free'
        assert user.sessions_used_this_month == 0
        assert user.can_create_session is True

    def test_can_create_session_limit(self):
        """Test session creation limit"""
        user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )

        # Set sessions to limit
        user.sessions_used_this_month = 50  # Free tier limit
        user.save()

        assert user.can_create_session is False


@pytest.mark.django_db
class TestTemplateCategory:
    """Test TemplateCategory model"""

    def test_create_category(self):
        """Test creating a template category"""
        category = TemplateCategory.objects.create(
            name='Test Category',
            slug='test-category',
            icon='🧪',
            order=1
        )

        assert category.name == 'Test Category'
        assert category.slug == 'test-category'
        assert category.is_active is True


@pytest.mark.django_db
class TestPromptTemplate:
    """Test PromptTemplate model"""

    def test_create_template(self):
        """Test creating a prompt template"""
        category = TemplateCategory.objects.create(
            name='Test Category',
            slug='test-category',
            icon='🧪'
        )

        template = PromptTemplate.objects.create(
            name='Test Template',
            slug='test-template',
            description='A test template',
            category=category,
            user_prompt_display='Test {variable}',
            prompt_template='Test template with {{ variable }}',
            variables_schema=[
                {
                    'name': 'variable',
                    'type': 'text',
                    'required': True
                }
            ]
        )

        assert template.name == 'Test Template'
        assert template.category == category
        assert template.usage_count == 0


@pytest.mark.django_db
class TestWhisperSession:
    """Test WhisperSession model"""

    def test_create_session(self):
        """Test creating a whisper session"""
        user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )

        category = TemplateCategory.objects.create(
            name='Test Category',
            slug='test-category',
            icon='🧪'
        )

        template = PromptTemplate.objects.create(
            name='Test Template',
            slug='test-template',
            description='A test template',
            category=category,
            user_prompt_display='Test',
            prompt_template='Test',
            variables_schema=[]
        )

        session = WhisperSession.objects.create(
            user=user,
            template=template
        )

        assert session.status == 'started'
        assert session.user == user
        assert session.template == template
