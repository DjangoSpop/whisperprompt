# AI Whisperer - Deployment Guide

This guide covers deploying the AI Whisperer backend to production environments.

## 🚀 Quick Deployment Options

### Option 1: Railway (Recommended)

Railway provides automatic deployments with PostgreSQL, Redis, and easy scaling.

#### Steps:

1. **Create Railway Account**
   - Go to [railway.app](https://railway.app)
   - Sign up with GitHub

2. **Create New Project**
   ```bash
   # Install Railway CLI
   npm install -g @railway/cli

   # Login
   railway login

   # Initialize project
   cd backend
   railway init
   ```

3. **Add Services**
   - PostgreSQL: `railway add postgresql`
   - Redis: `railway add redis`

4. **Set Environment Variables**
   ```bash
   railway variables set SECRET_KEY="your-secret-key-here"
   railway variables set OPENAI_API_KEY="sk-your-key-here"
   railway variables set DEBUG="False"
   railway variables set ALLOWED_HOSTS="your-app.railway.app"
   ```

5. **Deploy**
   ```bash
   railway up
   ```

6. **Run Initial Setup**
   ```bash
   railway run python manage.py migrate
   railway run python manage.py seed_templates
   railway run python manage.py createsuperuser
   ```

### Option 2: Docker + VPS

Deploy using Docker Compose on any VPS (DigitalOcean, Linode, AWS EC2, etc.)

#### Prerequisites:
- VPS with Ubuntu 22.04+
- Docker and Docker Compose installed
- Domain name (optional)

#### Steps:

1. **SSH into VPS**
   ```bash
   ssh user@your-server-ip
   ```

2. **Install Docker**
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker $USER
   ```

3. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd whisperprompt/backend
   ```

4. **Configure Environment**
   ```bash
   cp .env.example .env
   nano .env  # Edit with your values
   ```

5. **Start Services**
   ```bash
   docker-compose up -d
   ```

6. **Run Migrations**
   ```bash
   docker-compose exec web python manage.py migrate
   docker-compose exec web python manage.py seed_templates
   docker-compose exec web python manage.py createsuperuser
   ```

7. **Setup Nginx (Optional)**
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;

       location / {
           proxy_pass http://localhost:8000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }

       location /static/ {
           alias /path/to/staticfiles/;
       }

       location /media/ {
           alias /path/to/media/;
       }
   }
   ```

### Option 3: Render

1. **Create Render Account**
   - Go to [render.com](https://render.com)

2. **Create PostgreSQL Database**
   - New → PostgreSQL
   - Note the internal database URL

3. **Create Redis Instance**
   - New → Redis
   - Note the internal Redis URL

4. **Create Web Service**
   - New → Web Service
   - Connect your repository
   - Select `backend` folder
   - Build Command: `pip install -r requirements.txt && python manage.py collectstatic --noinput`
   - Start Command: `python manage.py migrate && python manage.py seed_templates && gunicorn ai_whisperer.wsgi:application`

5. **Add Environment Variables**
   - `SECRET_KEY`
   - `OPENAI_API_KEY`
   - `DATABASE_URL` (from PostgreSQL service)
   - `REDIS_URL` (from Redis service)
   - `ALLOWED_HOSTS` (your-app.onrender.com)
   - `DEBUG=False`

6. **Create Background Worker**
   - New → Background Worker
   - Same repository
   - Start Command: `celery -A ai_whisperer worker -l info`

## 🔧 Production Configuration

### Environment Variables

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `SECRET_KEY` | Yes | Django secret key | Random 50-char string |
| `DEBUG` | Yes | Debug mode | `False` |
| `ALLOWED_HOSTS` | Yes | Allowed hosts | `api.yourdomain.com` |
| `DATABASE_URL` | Yes | PostgreSQL connection | `postgresql://user:pass@host:5432/db` |
| `REDIS_URL` | Yes | Redis connection | `redis://localhost:6379/0` |
| `OPENAI_API_KEY` | Yes | OpenAI API key | `sk-...` |
| `CORS_ALLOWED_ORIGINS` | No | CORS origins | `https://app.yourdomain.com` |
| `USE_S3` | No | Use S3 storage | `True` or `False` |
| `CLOUDFLARE_R2_ACCESS_KEY` | If USE_S3 | R2 access key | - |
| `CLOUDFLARE_R2_SECRET_KEY` | If USE_S3 | R2 secret key | - |
| `CLOUDFLARE_R2_BUCKET` | If USE_S3 | R2 bucket name | - |
| `CLOUDFLARE_R2_ENDPOINT` | If USE_S3 | R2 endpoint URL | - |

### Generating Secret Keys

```bash
# Django SECRET_KEY
python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'

# JWT SECRET_KEY (can be same as SECRET_KEY or different)
python -c 'import secrets; print(secrets.token_urlsafe(50))'
```

## 📊 Monitoring

### Health Checks

```bash
# Check if API is responding
curl https://your-domain.com/admin/

# Check Celery workers
celery -A ai_whisperer inspect active
```

### Logs

```bash
# Docker
docker-compose logs -f web
docker-compose logs -f celery

# Railway
railway logs

# Heroku/Render
Check dashboard
```

## 🔄 CI/CD Setup

### GitHub Actions Example

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: |
          cd backend
          pip install -r requirements.txt
      - name: Run tests
        run: |
          cd backend
          pytest

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Railway
        run: |
          npm install -g @railway/cli
          railway up
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

## 🔐 Security Checklist

- [ ] Set `DEBUG=False` in production
- [ ] Use strong `SECRET_KEY` and `JWT_SECRET_KEY`
- [ ] Configure HTTPS/SSL
- [ ] Set up CORS correctly
- [ ] Enable rate limiting
- [ ] Configure allowed hosts
- [ ] Use environment variables (never commit secrets)
- [ ] Set up database backups
- [ ] Configure Cloudflare R2 for file storage
- [ ] Enable Django security headers
- [ ] Set up monitoring and alerts

## 📈 Scaling

### Horizontal Scaling

```yaml
# docker-compose.yml - scale workers
docker-compose up -d --scale celery=4
```

### Database Optimization

```sql
-- Add indexes (already in migrations)
-- Monitor slow queries
-- Set up connection pooling
```

### Caching

```python
# settings.py
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': os.getenv('REDIS_URL'),
    }
}
```

## 🆘 Troubleshooting

### Issue: Migrations failing

```bash
# Check database connection
python manage.py dbshell

# Reset migrations (CAUTION: Development only)
python manage.py migrate --fake core zero
python manage.py migrate
```

### Issue: Celery not processing tasks

```bash
# Check Celery workers
celery -A ai_whisperer inspect active

# Check Redis connection
redis-cli ping

# Restart workers
pkill -f 'celery worker'
celery -A ai_whisperer worker -l info
```

### Issue: Static files not loading

```bash
# Collect static files
python manage.py collectstatic --noinput

# Check STATIC_ROOT setting
python manage.py shell -c "from django.conf import settings; print(settings.STATIC_ROOT)"
```

## 📞 Support

For deployment issues:
1. Check logs first
2. Review this documentation
3. Check GitHub Issues
4. Contact development team

---

**Last Updated**: 2024-12-08
