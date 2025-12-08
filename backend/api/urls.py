"""
URL routing for API endpoints.
"""

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

from .views import (
    UserRegistrationView, UserProfileView,
    TemplateCategoryViewSet,
    PromptTemplateViewSet,
    WhisperSessionViewSet,
    PromptHistoryViewSet,
)

# Create router for viewsets
router = DefaultRouter()
router.register(r'categories', TemplateCategoryViewSet, basename='category')
router.register(r'templates', PromptTemplateViewSet, basename='template')
router.register(r'sessions', WhisperSessionViewSet, basename='session')
router.register(r'history', PromptHistoryViewSet, basename='history')

urlpatterns = [
    # Authentication
    path('auth/register/', UserRegistrationView.as_view(), name='register'),
    path('auth/login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/profile/', UserProfileView.as_view(), name='profile'),

    # Router URLs
    path('', include(router.urls)),
]
