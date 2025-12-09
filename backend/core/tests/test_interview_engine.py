"""
Tests for Interview Engine service.
"""

import pytest
from django.contrib.auth import get_user_model
from core.models import TemplateCategory, PromptTemplate, WhisperSession
from core.services import InterviewEngine

User = get_user_model()


@pytest.mark.django_db
class TestInterviewEngine:
    """Test Interview Engine"""

    @pytest.fixture
    def user(self):
        """Create test user"""
        return User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )

    @pytest.fixture
    def template(self):
        """Create test template"""
        category = TemplateCategory.objects.create(
            name='Test Category',
            slug='test-category',
            icon='🧪'
        )

        return PromptTemplate.objects.create(
            name='Test Template',
            slug='test-template',
            description='A test template',
            category=category,
            user_prompt_display='Write {topic} in {tone} tone',
            prompt_template='Topic: {{ topic }}\nTone: {{ tone }}',
            variables_schema=[
                {
                    'name': 'topic',
                    'type': 'text',
                    'required': True
                },
                {
                    'name': 'tone',
                    'type': 'choice',
                    'options': ['formal', 'casual'],
                    'default': 'formal'
                }
            ]
        )

    def test_engine_initialization(self, user, template):
        """Test engine initialization"""
        session = WhisperSession.objects.create(
            user=user,
            template=template
        )

        engine = InterviewEngine(session)

        assert engine.session == session
        assert engine.template == template

    def test_get_required_variables(self, user, template):
        """Test getting required variables"""
        session = WhisperSession.objects.create(
            user=user,
            template=template
        )

        engine = InterviewEngine(session)
        required = engine.get_required_variables()

        assert len(required) == 1
        assert required[0]['name'] == 'topic'

    def test_is_ready_to_generate(self, user, template):
        """Test ready to generate check"""
        session = WhisperSession.objects.create(
            user=user,
            template=template,
            variables_input={'topic': 'AI Development'}
        )

        engine = InterviewEngine(session)

        assert engine.is_ready_to_generate() is True

    def test_process_variable_text(self, user, template):
        """Test processing text variable"""
        session = WhisperSession.objects.create(
            user=user,
            template=template
        )

        engine = InterviewEngine(session)
        result = engine.process_variable('topic', '  AI Development  ')

        assert result == 'AI Development'

    def test_process_variable_choice(self, user, template):
        """Test processing choice variable"""
        session = WhisperSession.objects.create(
            user=user,
            template=template
        )

        engine = InterviewEngine(session)

        # Exact match
        result = engine.process_variable('tone', 'formal')
        assert result == 'formal'

        # Fuzzy match
        result = engine.process_variable('tone', 'I want it formal please')
        assert result == 'formal'

    def test_match_choice(self, user, template):
        """Test choice matching logic"""
        session = WhisperSession.objects.create(
            user=user,
            template=template
        )

        engine = InterviewEngine(session)

        # Exact match
        result = engine._match_choice('formal', ['formal', 'casual'])
        assert result == 'formal'

        # Partial match
        result = engine._match_choice('make it formal', ['formal', 'casual'])
        assert result == 'formal'

        # No match
        result = engine._match_choice('unknown', ['formal', 'casual'])
        assert result is None

    def test_apply_transformations(self, user, template):
        """Test variable transformations"""
        session = WhisperSession.objects.create(
            user=user,
            template=template
        )

        engine = InterviewEngine(session)

        variables = {
            'topic': 'AI Development',
            'tone': 'formal'
        }

        transformed = engine.apply_transformations(variables)

        assert transformed['topic'] == 'AI Development'
        assert transformed['tone'] == 'formal and professional'

    def test_generate_prompt(self, user, template):
        """Test prompt generation"""
        session = WhisperSession.objects.create(
            user=user,
            template=template,
            variables_input={
                'topic': 'AI Development',
                'tone': 'formal'
            }
        )

        engine = InterviewEngine(session)
        prompt = engine.generate_prompt()

        assert 'AI Development' in prompt
        assert 'formal and professional' in prompt
        assert session.status == 'completed'
        assert session.generated_prompt == prompt
