"""
Interview Engine - Core service for processing voice inputs and generating prompts.

This engine does NOT use AI/LLM - it uses pure template processing with smart
variable extraction and transformation.
"""

from django.template import Template, Context
from django.utils import timezone
from typing import Dict, Any, Optional, List
import logging

logger = logging.getLogger(__name__)


class InterviewEngine:
    """
    Core engine for processing voice inputs and generating prompts.
    NO AI/LLM - pure template processing.
    """

    # Transformation mappings for expanding shorthand values
    TRANSFORMATIONS = {
        'tone': {
            'formal': 'formal and professional',
            'casual': 'casual and friendly',
            'urgent': 'urgent and action-oriented',
            'friendly': 'warm and approachable',
            'persuasive': 'persuasive and compelling',
            'authoritative': 'authoritative and confident',
            'empathetic': 'empathetic and understanding',
        },
        'length': {
            'short': 'brief (1-2 paragraphs)',
            'medium': 'moderate (3-4 paragraphs)',
            'long': 'comprehensive (5+ paragraphs)',
            'very short': 'very brief (1 paragraph)',
            'very long': 'extensive (6+ paragraphs)',
        },
        'audience': {
            'technical': 'technical audience familiar with jargon',
            'general': 'general audience, avoid jargon',
            'executive': 'executive level, focus on impact and ROI',
            'beginner': 'beginners, explain concepts simply',
            'expert': 'expert audience, use advanced terminology',
            'children': 'children, use simple language and examples',
        },
        'format': {
            'email': 'email format with subject, greeting, body, sign-off',
            'list': 'numbered or bulleted list',
            'paragraph': 'flowing paragraphs',
            'steps': 'step-by-step instructions',
            'outline': 'structured outline with headers',
            'report': 'formal report structure',
        },
        'style': {
            'concise': 'concise and to-the-point',
            'detailed': 'detailed with thorough explanations',
            'creative': 'creative and engaging',
            'straightforward': 'straightforward and direct',
            'narrative': 'narrative storytelling style',
        }
    }

    def __init__(self, session):
        """
        Initialize the engine with a WhisperSession.

        Args:
            session: WhisperSession instance
        """
        self.session = session
        self.template = session.template

        if not self.template:
            raise ValueError("Session must have a template")

    def get_required_variables(self) -> List[Dict[str, Any]]:
        """
        Get list of variables that still need input.

        Returns:
            List of variable definitions that are required but not yet collected
        """
        schema = self.template.variables_schema
        collected = self.session.variables_input

        required = []
        for var in schema:
            if var.get('required', False) and var['name'] not in collected:
                required.append(var)

        return required

    def is_ready_to_generate(self) -> bool:
        """
        Check if all required variables are collected.

        Returns:
            bool: True if ready to generate prompt
        """
        return len(self.get_required_variables()) == 0

    def process_variable(self, name: str, raw_value: str) -> str:
        """
        Process a raw transcribed value into the final variable value.
        Handles normalization, choice matching, and transformations.

        Args:
            name: Variable name
            raw_value: Raw transcribed text

        Returns:
            Processed variable value
        """
        schema = self._get_variable_schema(name)
        if not schema:
            return raw_value.strip()

        value = raw_value.strip()
        var_type = schema.get('type', 'text')

        # Handle choice type - match to closest option
        if var_type == 'choice':
            options = schema.get('options', [])
            matched = self._match_choice(value, options)
            return matched or schema.get('default', options[0] if options else value)

        # Handle boolean type
        if var_type == 'boolean':
            return self._parse_boolean(value)

        # Text type - return cleaned value
        return value

    def _match_choice(self, value: str, options: List[str]) -> Optional[str]:
        """
        Fuzzy match voice input to available options.

        Args:
            value: User's voice input (transcribed)
            options: Available option values

        Returns:
            Matched option or None
        """
        value_lower = value.lower()

        # Exact match
        for opt in options:
            if opt.lower() == value_lower:
                return opt

        # Partial match
        for opt in options:
            if opt.lower() in value_lower or value_lower in opt.lower():
                return opt

        # Keyword match dictionary
        keywords = {
            'formal': ['formal', 'professional', 'business', 'official'],
            'casual': ['casual', 'informal', 'relaxed', 'friendly', 'conversational'],
            'urgent': ['urgent', 'asap', 'immediately', 'rush', 'emergency'],
            'short': ['short', 'brief', 'quick', 'concise', 'succinct'],
            'medium': ['medium', 'moderate', 'normal', 'standard', 'regular'],
            'long': ['long', 'detailed', 'comprehensive', 'thorough', 'extensive'],
            'technical': ['technical', 'developer', 'engineer', 'programmer'],
            'general': ['general', 'everyone', 'public', 'broad'],
            'executive': ['executive', 'manager', 'leadership', 'c-level'],
            'beginner': ['beginner', 'novice', 'new', 'starter', 'learning'],
        }

        # Try keyword matching
        for opt in options:
            opt_lower = opt.lower()
            if opt_lower in keywords:
                for keyword in keywords[opt_lower]:
                    if keyword in value_lower:
                        return opt

        return None

    def _parse_boolean(self, value: str) -> bool:
        """
        Parse voice input to boolean.

        Args:
            value: Transcribed voice input

        Returns:
            Boolean value
        """
        true_words = ['yes', 'yeah', 'yep', 'yup', 'true', 'sure', 'ok', 'okay',
                      'definitely', 'absolutely', 'correct', 'right', 'affirmative']
        value_lower = value.lower()
        return any(word in value_lower for word in true_words)

    def _get_variable_schema(self, name: str) -> Optional[Dict[str, Any]]:
        """
        Get schema definition for a specific variable.

        Args:
            name: Variable name

        Returns:
            Variable schema dict or None
        """
        for var in self.template.variables_schema:
            if var['name'] == name:
                return var
        return None

    def apply_transformations(self, variables: Dict[str, Any]) -> Dict[str, Any]:
        """
        Apply transformations to expand shorthand values.

        Args:
            variables: Dictionary of variable name -> value

        Returns:
            Dictionary with transformed values
        """
        transformed = {}

        for name, value in variables.items():
            # Convert to string and lowercase for matching
            value_str = str(value).lower().strip()

            # Check if this variable has a transformation mapping
            if name in self.TRANSFORMATIONS:
                if value_str in self.TRANSFORMATIONS[name]:
                    transformed[name] = self.TRANSFORMATIONS[name][value_str]
                    logger.debug(f"Transformed {name}: {value} -> {transformed[name]}")
                else:
                    transformed[name] = value
            else:
                transformed[name] = value

        return transformed

    def generate_prompt(self) -> str:
        """
        Generate the final prompt from template and variables.

        Returns:
            Generated prompt text

        Raises:
            ValueError: If not ready to generate (missing required variables)
        """
        if not self.is_ready_to_generate():
            missing = [v['name'] for v in self.get_required_variables()]
            raise ValueError(f"Missing required variables: {', '.join(missing)}")

        logger.info(f"Generating prompt for session {self.session.id}")

        # Process all raw inputs
        processed_vars = {}
        for name, raw_value in self.session.variables_input.items():
            processed_vars[name] = self.process_variable(name, raw_value)
            logger.debug(f"Processed {name}: {raw_value} -> {processed_vars[name]}")

        # Apply transformations
        transformed_vars = self.apply_transformations(processed_vars)

        # Fill in defaults for missing optional variables
        for var in self.template.variables_schema:
            if var['name'] not in transformed_vars:
                if 'default' in var:
                    transformed_vars[var['name']] = var['default']
                    logger.debug(f"Using default for {var['name']}: {var['default']}")

        # Render template using Django template engine
        template = Template(self.template.prompt_template)
        context = Context(transformed_vars)
        prompt = template.render(context)

        # Update session
        self.session.variables_processed = transformed_vars
        self.session.generated_prompt = prompt
        self.session.status = 'completed'
        self.session.completed_at = timezone.now()
        self.session.save()

        logger.info(f"Successfully generated prompt for session {self.session.id}")

        # Create history entry
        self._create_history_entry(prompt, transformed_vars)

        # Increment template usage
        self.template.usage_count += 1
        self.template.save(update_fields=['usage_count'])

        return prompt

    def _create_history_entry(self, prompt: str, variables: Dict[str, Any]):
        """
        Create a history entry for this session.

        Args:
            prompt: Generated prompt text
            variables: Processed variables dictionary
        """
        from ..models import PromptHistory

        # Create history entry
        history, created = PromptHistory.objects.get_or_create(
            user=self.session.user,
            session=self.session,
            defaults={
                'template_name': self.template.name,
                'template_category': self.template.category.name,
                'prompt_preview': prompt[:200],
                'full_prompt': prompt,
                'variables_used': variables,
            }
        )

        if created:
            logger.info(f"Created history entry {history.id} for session {self.session.id}")
        else:
            logger.warning(f"History entry already exists for session {self.session.id}")

        return history

    def get_session_status(self) -> Dict[str, Any]:
        """
        Get current status of the session including variable collection progress.

        Returns:
            Dictionary with session status information
        """
        from ..models import VoiceInput

        variables_status = {}

        # Get status for each variable in the template
        for var in self.template.variables_schema:
            var_name = var['name']

            # Check if we have a voice input for this variable
            voice_input = VoiceInput.objects.filter(
                session=self.session,
                variable_name=var_name
            ).first()

            if voice_input:
                variables_status[var_name] = {
                    'status': voice_input.transcription_status,
                    'transcribed_text': voice_input.transcribed_text,
                    'required': var.get('required', False),
                }
            else:
                variables_status[var_name] = {
                    'status': 'pending',
                    'transcribed_text': None,
                    'required': var.get('required', False),
                }

        return {
            'session_id': str(self.session.id),
            'status': self.session.status,
            'variables_status': variables_status,
            'ready_to_generate': self.is_ready_to_generate(),
            'template_name': self.template.name,
        }
