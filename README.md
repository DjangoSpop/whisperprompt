# AI Whisperer - MVP Backend

> **"No AI needed to craft AI prompts"**

AI Whisperer is a voice-powered prompt generation tool that uses templates and smart variable extraction instead of expensive LLM calls.

## 🎯 Key Features

- **Voice Input**: Speak variables instead of typing long prompts
- **Template-Based**: Pre-built templates for common use cases
- **Zero LLM Cost**: Uses templates and string replacement (only Whisper API for transcription)
- **Instant Results**: No waiting for AI to generate responses
- **History Management**: Save and reuse your favorite prompts

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    DJANGO BACKEND                       │
│  ┌─────────────┐    ┌─────────────┐    ┌────────────┐  │
│  │   REST API  │───▶│  Interview  │───▶│   Prompt   │  │
│  │    (DRF)    │    │   Engine    │    │ Generator  │  │
│  └─────────────┘    └─────────────┘    └────────────┘  │
│         │                                       │        │
│         ▼                                       ▼        │
│  ┌─────────────┐    ┌─────────────┐    ┌────────────┐  │
│  │   Celery    │◄──▶│    Redis    │    │ PostgreSQL │  │
│  │   Workers   │    │   (Broker)  │    │            │  │
│  └──────┬──────┘    └─────────────┘    └────────────┘  │
│         │                                                │
│         ▼                                                │
│  ┌─────────────┐                                        │
│  │  Whisper    │                                        │
│  │ (OpenAI API)│                                        │
│  └─────────────┘                                        │
└─────────────────────────────────────────────────────────┘
```

## 📋 Prerequisites

- Python 3.11+
- PostgreSQL 14+ (or SQLite for development)
- Redis 7+
- OpenAI API Key (for Whisper transcription)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd whisperprompt/backend
```

### 2. Create Virtual Environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Environment Configuration

```bash
cp .env.example .env
```

Edit `.env` and configure:
- `SECRET_KEY`: Generate a secure key
- `OPENAI_API_KEY`: Your OpenAI API key for Whisper
- `DATABASE_URL`: PostgreSQL connection string (optional for dev)
- `REDIS_URL`: Redis connection string

### 5. Run Migrations

```bash
python manage.py migrate
```

### 6. Seed Templates

```bash
python manage.py seed_templates
```

This will create:
- 5 template categories
- 8 MVP prompt templates

### 7. Create Superuser (Optional)

```bash
python manage.py createsuperuser
```

### 8. Start Development Server

```bash
python manage.py runserver
```

API will be available at: `http://localhost:8000/api/v1/`

### 9. Start Celery Worker (Separate Terminal)

```bash
# Make sure Redis is running first
redis-server

# In a new terminal
celery -A ai_whisperer worker -l info
```

### 10. Start Celery Beat (Optional - for scheduled tasks)

```bash
celery -A ai_whisperer beat -l info
```

## 📚 API Documentation

### Authentication

#### Register
```http
POST /api/v1/auth/register/
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "password": "securepassword123",
  "password_confirm": "securepassword123"
}
```

#### Login
```http
POST /api/v1/auth/login/
Content-Type: application/json

{
  "username": "testuser",
  "password": "securepassword123"
}
```

Returns JWT tokens:
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

### Templates

#### List Categories
```http
GET /api/v1/categories/
Authorization: Bearer {access_token}
```

#### List Templates
```http
GET /api/v1/templates/
Authorization: Bearer {access_token}
```

Query parameters:
- `category`: Filter by category slug

#### Get Template Details
```http
GET /api/v1/templates/{slug}/
Authorization: Bearer {access_token}
```

### Sessions

#### Create Session
```http
POST /api/v1/sessions/
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "template_slug": "email-writer"
}
```

#### Upload Voice Input
```http
POST /api/v1/sessions/{session_id}/voice/
Authorization: Bearer {access_token}
Content-Type: multipart/form-data

variable_name: topic
audio_file: [audio file]
audio_duration_ms: 3000
```

#### Check Session Status
```http
GET /api/v1/sessions/{session_id}/status/
Authorization: Bearer {access_token}
```

#### Generate Prompt
```http
POST /api/v1/sessions/{session_id}/generate/
Authorization: Bearer {access_token}
```

### History

#### List History
```http
GET /api/v1/history/
Authorization: Bearer {access_token}
```

Query parameters:
- `favorites`: Filter favorites only (`true`)
- `category`: Filter by category name

#### Get History Details
```http
GET /api/v1/history/{history_id}/
Authorization: Bearer {access_token}
```

#### Track Copy
```http
POST /api/v1/history/{history_id}/copy/
Authorization: Bearer {access_token}
```

#### Toggle Favorite
```http
PATCH /api/v1/history/{history_id}/favorite/
Authorization: Bearer {access_token}
```

## 🧪 Testing

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=core --cov=api

# Run specific test file
pytest core/tests/test_models.py
```

## 📦 Project Structure

```
backend/
├── ai_whisperer/          # Django project settings
│   ├── settings.py
│   ├── celery.py
│   ├── urls.py
│   └── wsgi.py
├── core/                  # Core app
│   ├── models.py          # Database models
│   ├── tasks.py           # Celery tasks
│   ├── admin.py           # Django admin
│   ├── signals.py         # Signal handlers
│   ├── services/
│   │   └── interview_engine.py  # Template processing engine
│   └── management/
│       └── commands/
│           └── seed_templates.py
├── api/                   # API app
│   ├── views.py           # API endpoints
│   ├── serializers.py     # DRF serializers
│   └── urls.py            # API routing
├── requirements.txt
└── manage.py
```

## 🔧 Configuration

### Database

Development uses SQLite by default. For production, configure PostgreSQL:

```bash
DATABASE_URL=postgresql://user:password@localhost:5432/ai_whisperer
```

### Redis

Required for Celery task queue:

```bash
REDIS_URL=redis://localhost:6379/0
```

### File Storage

Local filesystem is used by default. For production, configure Cloudflare R2:

```bash
USE_S3=True
CLOUDFLARE_R2_ACCESS_KEY=your-access-key
CLOUDFLARE_R2_SECRET_KEY=your-secret-key
CLOUDFLARE_R2_BUCKET=your-bucket-name
CLOUDFLARE_R2_ENDPOINT=https://your-account-id.r2.cloudflarestorage.com
```

## 🚀 Deployment

### Production Checklist

1. Set `DEBUG=False`
2. Configure strong `SECRET_KEY`
3. Set up PostgreSQL database
4. Configure Redis
5. Set up Cloudflare R2 for file storage
6. Configure allowed hosts
7. Run migrations
8. Seed templates
9. Collect static files: `python manage.py collectstatic`
10. Start Gunicorn: `gunicorn ai_whisperer.wsgi:application`
11. Start Celery worker and beat

### Environment Variables (Production)

```bash
SECRET_KEY=<strong-random-key>
DEBUG=False
ALLOWED_HOSTS=api.aiwhisperer.app
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
OPENAI_API_KEY=sk-...
USE_S3=True
# ... other R2 config
```

## 📝 License

MIT License - See LICENSE file for details

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write/update tests
5. Submit a pull request

## 📞 Support

For issues and questions:
- GitHub Issues: [Create an issue]
- Documentation: [See docs]

---

**Built with ❤️ for the AI Whisperer MVP**
