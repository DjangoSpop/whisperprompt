#!/bin/bash

# AI Whisperer - Quick Start Script
# This script sets up the development environment quickly

set -e  # Exit on error

echo "🚀 AI Whisperer - Quick Start Setup"
echo "==================================="
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.11+ first."
    exit 1
fi

echo "✓ Python $(python3 --version) found"
echo ""

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
    echo "✓ Virtual environment created"
else
    echo "✓ Virtual environment already exists"
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "📦 Upgrading pip..."
pip install --upgrade pip setuptools wheel --quiet

# Install dependencies
echo "📦 Installing Python dependencies..."
pip install -r requirements.txt --quiet
echo "✓ Dependencies installed"
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚙️  Creating .env file from example..."
    cp .env.example .env
    echo "✓ .env file created"
    echo ""
    echo "⚠️  IMPORTANT: Please edit .env file and add:"
    echo "   - OPENAI_API_KEY (required for Whisper transcription)"
    echo "   - SECRET_KEY (generate a secure key)"
    echo "   - JWT_SECRET_KEY (generate a secure key)"
    echo ""
else
    echo "✓ .env file exists"
fi

# Run migrations
echo "🗄️  Running database migrations..."
python manage.py makemigrations core
python manage.py migrate
echo "✓ Migrations complete"
echo ""

# Seed templates
echo "🌱 Seeding MVP templates..."
python manage.py seed_templates
echo "✓ Templates seeded"
echo ""

# Ask if user wants to create superuser
read -p "📝 Create Django superuser? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    python manage.py createsuperuser
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "🎯 Next steps:"
echo "   1. Make sure Redis is running: redis-server"
echo "   2. Start Django server: python manage.py runserver"
echo "   3. Start Celery worker: celery -A ai_whisperer worker -l info"
echo "   4. (Optional) Start Celery beat: celery -A ai_whisperer beat -l info"
echo ""
echo "📚 API will be available at: http://localhost:8000/api/v1/"
echo "🔧 Admin panel: http://localhost:8000/admin/"
echo ""
echo "Happy coding! 🎉"
