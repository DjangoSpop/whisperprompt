"""
Management command to seed MVP templates into the database.
"""

from django.core.management.base import BaseCommand
from core.models import TemplateCategory, PromptTemplate


class Command(BaseCommand):
    help = 'Seed MVP prompt templates'

    def handle(self, *args, **options):
        self.stdout.write('Seeding template categories...')

        # Create categories
        categories_data = [
            {
                'name': 'Communication',
                'slug': 'communication',
                'icon': '📧',
                'description': 'Templates for emails, messages, and professional communication',
                'order': 1
            },
            {
                'name': 'Development',
                'slug': 'development',
                'icon': '💻',
                'description': 'Templates for code, documentation, and technical content',
                'order': 2
            },
            {
                'name': 'Content',
                'slug': 'content',
                'icon': '✍️',
                'description': 'Templates for blogs, articles, and creative writing',
                'order': 3
            },
            {
                'name': 'Analysis',
                'slug': 'analysis',
                'icon': '📊',
                'description': 'Templates for data analysis, reports, and insights',
                'order': 4
            },
            {
                'name': 'Learning',
                'slug': 'learning',
                'icon': '📚',
                'description': 'Templates for education, tutorials, and explanations',
                'order': 5
            },
        ]

        categories = {}
        for cat_data in categories_data:
            category, created = TemplateCategory.objects.get_or_create(
                slug=cat_data['slug'],
                defaults=cat_data
            )
            categories[cat_data['slug']] = category
            if created:
                self.stdout.write(self.style.SUCCESS(f'✓ Created category: {category.name}'))
            else:
                self.stdout.write(f'  Category exists: {category.name}')

        self.stdout.write('\nSeeding prompt templates...')

        # Define all MVP templates
        templates_data = [
            # Communication Templates
            {
                'slug': 'email-writer',
                'name': 'Email Writer',
                'category': 'communication',
                'description': 'Write professional emails quickly with the perfect tone',
                'user_prompt_display': 'Write me an email about {topic} make it {tone}',
                'variables_schema': [
                    {
                        'name': 'topic',
                        'type': 'text',
                        'required': True,
                        'voice_hint': "What's the email about?",
                        'examples': ['project delay', 'meeting request', 'follow up']
                    },
                    {
                        'name': 'tone',
                        'type': 'choice',
                        'required': False,
                        'voice_hint': 'What tone? Formal, casual, or urgent?',
                        'options': ['formal', 'casual', 'urgent', 'friendly'],
                        'default': 'formal'
                    }
                ],
                'prompt_template': '''You are a professional email writer.

Write an email about: {{ topic }}
Tone: {{ tone }}

Include:
- Clear subject line
- Appropriate greeting
- Concise body (3-4 paragraphs)
- Professional sign-off
- Match the specified tone throughout

Output the complete email ready to send.''',
                'estimated_tokens': 200,
                'best_for': ['ChatGPT', 'Claude', 'Gemini'],
                'tags': ['email', 'business', 'communication'],
            },
            {
                'slug': 'meeting-summary',
                'name': 'Meeting Summary',
                'category': 'communication',
                'description': 'Create professional meeting summaries with action items',
                'user_prompt_display': 'Summarize a meeting about {topic}',
                'variables_schema': [
                    {
                        'name': 'topic',
                        'type': 'text',
                        'required': True,
                        'voice_hint': 'What was the meeting about?',
                    },
                    {
                        'name': 'attendees',
                        'type': 'text',
                        'required': False,
                        'voice_hint': 'Who attended?',
                        'default': 'team members'
                    },
                    {
                        'name': 'key_decisions',
                        'type': 'text',
                        'required': True,
                        'voice_hint': 'What were the main decisions?',
                    },
                    {
                        'name': 'action_items',
                        'type': 'text',
                        'required': True,
                        'voice_hint': 'What are the next steps?',
                    }
                ],
                'prompt_template': '''Format this as a professional meeting summary.

Meeting Topic: {{ topic }}
Attendees: {{ attendees }}

Key Decisions:
{{ key_decisions }}

Action Items:
{{ action_items }}

Format with:
- Executive summary (2-3 sentences)
- Decisions made (bullet points)
- Action items with suggested owners and deadlines
- Next meeting date placeholder''',
                'estimated_tokens': 250,
                'best_for': ['ChatGPT', 'Claude'],
                'tags': ['meeting', 'summary', 'business'],
            },

            # Development Templates
            {
                'slug': 'code-explainer',
                'name': 'Code Explainer',
                'category': 'development',
                'description': 'Explain code to any audience level',
                'user_prompt_display': 'Explain {language} code for {audience}',
                'variables_schema': [
                    {
                        'name': 'language',
                        'type': 'text',
                        'required': True,
                        'voice_hint': 'What programming language?',
                    },
                    {
                        'name': 'audience',
                        'type': 'choice',
                        'required': False,
                        'voice_hint': 'What audience level?',
                        'options': ['beginner', 'intermediate', 'expert'],
                        'default': 'beginner'
                    },
                    {
                        'name': 'code_description',
                        'type': 'text',
                        'required': True,
                        'voice_hint': 'Describe the code',
                    }
                ],
                'prompt_template': '''You are a coding instructor.

Explain this {{ language }} code:
{{ code_description }}

Audience level: {{ audience }}

Provide:
- Overview of what the code does
- Key concepts and patterns used
- Line-by-line explanation where helpful
- Common use cases
- Potential improvements or best practices''',
                'estimated_tokens': 300,
                'best_for': ['ChatGPT', 'Claude', 'Gemini'],
                'tags': ['code', 'programming', 'explanation'],
            },
            {
                'slug': 'bug-report',
                'name': 'Bug Report',
                'category': 'development',
                'description': 'Create detailed bug reports',
                'user_prompt_display': 'Write a bug report for {issue} in {application}',
                'variables_schema': [
                    {
                        'name': 'application',
                        'type': 'text',
                        'required': True,
                        'voice_hint': 'Which app or system?',
                    },
                    {
                        'name': 'issue',
                        'type': 'text',
                        'required': True,
                        'voice_hint': 'Describe the bug',
                    },
                    {
                        'name': 'severity',
                        'type': 'choice',
                        'required': False,
                        'voice_hint': 'How severe is it?',
                        'options': ['critical', 'high', 'medium', 'low'],
                        'default': 'medium'
                    },
                    {
                        'name': 'steps_to_reproduce',
                        'type': 'text',
                        'required': True,
                        'voice_hint': 'How to reproduce it?',
                    }
                ],
                'prompt_template': '''Create a detailed bug report.

Application: {{ application }}
Issue: {{ issue }}
Severity: {{ severity }}
Steps to reproduce: {{ steps_to_reproduce }}

Format as:
- Title (concise bug description)
- Environment details section
- Steps to reproduce (numbered list)
- Expected vs actual behavior
- Screenshots/logs placeholder
- Severity justification
- Suggested fix (if applicable)''',
                'estimated_tokens': 250,
                'best_for': ['ChatGPT', 'Claude'],
                'tags': ['bug', 'development', 'testing'],
            },

            # Content Templates
            {
                'slug': 'blog-outline',
                'name': 'Blog Post Outline',
                'category': 'content',
                'description': 'Create structured blog post outlines',
                'user_prompt_display': 'Create a blog outline about {topic}',
                'variables_schema': [
                    {
                        'name': 'topic',
                        'type': 'text',
                        'required': True,
                        'voice_hint': "What's the blog topic?",
                    },
                    {
                        'name': 'length',
                        'type': 'choice',
                        'required': False,
                        'voice_hint': 'How long should it be?',
                        'options': ['short', 'medium', 'long'],
                        'default': 'medium'
                    },
                    {
                        'name': 'target_audience',
                        'type': 'text',
                        'required': False,
                        'voice_hint': 'Who is the target audience?',
                        'default': 'general readers'
                    }
                ],
                'prompt_template': '''Create a blog post outline.

Topic: {{ topic }}
Length: {{ length }}
Audience: {{ target_audience }}

Include:
- 3 engaging title options
- Hook for introduction
- Main sections with 2-3 subpoints each
- Key takeaways
- Call-to-action for conclusion
- SEO keywords suggestion''',
                'estimated_tokens': 300,
                'best_for': ['ChatGPT', 'Claude', 'Gemini'],
                'tags': ['blog', 'content', 'writing'],
            },
            {
                'slug': 'social-media-post',
                'name': 'Social Media Post',
                'category': 'content',
                'description': 'Create engaging social media content',
                'user_prompt_display': 'Write a {platform} post about {topic}',
                'variables_schema': [
                    {
                        'name': 'platform',
                        'type': 'choice',
                        'required': True,
                        'voice_hint': 'Which platform?',
                        'options': ['twitter', 'linkedin', 'facebook', 'instagram'],
                    },
                    {
                        'name': 'topic',
                        'type': 'text',
                        'required': True,
                        'voice_hint': "What's the post about?",
                    },
                    {
                        'name': 'tone',
                        'type': 'choice',
                        'required': False,
                        'voice_hint': 'What tone?',
                        'options': ['professional', 'casual', 'humorous', 'inspirational'],
                        'default': 'casual'
                    }
                ],
                'prompt_template': '''Create a social media post for {{ platform }}.

Topic: {{ topic }}
Tone: {{ tone }}

Requirements:
- Platform-appropriate length and format
- Engaging hook in first line
- Clear message
- Relevant hashtags (3-5)
- Call-to-action if appropriate
- Match the specified tone''',
                'estimated_tokens': 150,
                'best_for': ['ChatGPT', 'Claude', 'Gemini'],
                'tags': ['social media', 'content', 'marketing'],
            },

            # Analysis Templates
            {
                'slug': 'data-analysis',
                'name': 'Data Analysis Request',
                'category': 'analysis',
                'description': 'Request comprehensive data analysis',
                'user_prompt_display': 'Analyze {data_type} data for {purpose}',
                'variables_schema': [
                    {
                        'name': 'data_type',
                        'type': 'text',
                        'required': True,
                        'voice_hint': 'What type of data?',
                    },
                    {
                        'name': 'purpose',
                        'type': 'text',
                        'required': True,
                        'voice_hint': 'What is the analysis purpose?',
                    },
                    {
                        'name': 'metrics',
                        'type': 'text',
                        'required': False,
                        'voice_hint': 'What metrics to focus on?',
                        'default': 'key performance indicators'
                    }
                ],
                'prompt_template': '''Analyze the following data.

Data Type: {{ data_type }}
Purpose: {{ purpose }}
Key Metrics: {{ metrics }}

Provide:
- Data overview and summary statistics
- Key findings and insights
- Trends and patterns
- Actionable recommendations
- Visualizations suggestions
- Potential limitations or caveats''',
                'estimated_tokens': 350,
                'best_for': ['ChatGPT', 'Claude'],
                'tags': ['data', 'analysis', 'insights'],
            },

            # Learning Templates
            {
                'slug': 'explain-concept',
                'name': 'Concept Explainer',
                'category': 'learning',
                'description': 'Explain complex concepts simply',
                'user_prompt_display': 'Explain {concept} to {audience}',
                'variables_schema': [
                    {
                        'name': 'concept',
                        'type': 'text',
                        'required': True,
                        'voice_hint': 'What concept to explain?',
                    },
                    {
                        'name': 'audience',
                        'type': 'choice',
                        'required': False,
                        'voice_hint': 'What audience level?',
                        'options': ['child', 'beginner', 'intermediate', 'expert'],
                        'default': 'beginner'
                    },
                    {
                        'name': 'use_examples',
                        'type': 'boolean',
                        'required': False,
                        'voice_hint': 'Include examples?',
                        'default': True
                    }
                ],
                'prompt_template': '''Explain the following concept.

Concept: {{ concept }}
Audience: {{ audience }}
Use examples: {{ use_examples }}

Provide:
- Clear, simple definition
- Why it matters
- How it works
{% if use_examples %}- Real-world examples{% endif %}
- Common misconceptions
- Related concepts
- Further learning resources''',
                'estimated_tokens': 250,
                'best_for': ['ChatGPT', 'Claude', 'Gemini'],
                'tags': ['education', 'explanation', 'learning'],
            },
        ]

        # Create templates
        for template_data in templates_data:
            category_slug = template_data.pop('category')
            template_data['category'] = categories[category_slug]

            template, created = PromptTemplate.objects.get_or_create(
                slug=template_data['slug'],
                defaults=template_data
            )

            if created:
                self.stdout.write(self.style.SUCCESS(f'✓ Created template: {template.name}'))
            else:
                self.stdout.write(f'  Template exists: {template.name}')

        self.stdout.write(self.style.SUCCESS(f'\n✓ Seeding complete!'))
        self.stdout.write(f'  Categories: {TemplateCategory.objects.count()}')
        self.stdout.write(f'  Templates: {PromptTemplate.objects.filter(is_active=True).count()}')
