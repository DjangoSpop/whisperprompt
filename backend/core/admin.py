"""
Django admin configuration for core models.
"""

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, TemplateCategory, PromptTemplate, WhisperSession, VoiceInput, PromptHistory


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    """Admin interface for User model"""
    list_display = ['username', 'email', 'subscription_tier', 'sessions_used_this_month', 'is_active', 'date_joined']
    list_filter = ['subscription_tier', 'is_active', 'is_staff', 'date_joined']
    search_fields = ['username', 'email', 'first_name', 'last_name']
    ordering = ['-date_joined']

    fieldsets = BaseUserAdmin.fieldsets + (
        ('Subscription', {
            'fields': ('subscription_tier', 'sessions_used_this_month', 'sessions_reset_date'),
        }),
        ('Additional Info', {
            'fields': ('phone',),
        }),
    )


@admin.register(TemplateCategory)
class TemplateCategoryAdmin(admin.ModelAdmin):
    """Admin interface for TemplateCategory model"""
    list_display = ['name', 'slug', 'icon', 'order', 'is_active', 'created_at']
    list_filter = ['is_active']
    search_fields = ['name', 'slug', 'description']
    prepopulated_fields = {'slug': ('name',)}
    ordering = ['order', 'name']


@admin.register(PromptTemplate)
class PromptTemplateAdmin(admin.ModelAdmin):
    """Admin interface for PromptTemplate model"""
    list_display = ['name', 'category', 'is_active', 'is_premium', 'usage_count', 'created_at']
    list_filter = ['category', 'is_active', 'is_premium', 'created_at']
    search_fields = ['name', 'slug', 'description', 'tags']
    prepopulated_fields = {'slug': ('name',)}
    readonly_fields = ['usage_count', 'created_at', 'updated_at']
    ordering = ['-usage_count', 'name']

    fieldsets = (
        ('Basic Information', {
            'fields': ('name', 'slug', 'description', 'category'),
        }),
        ('Template Content', {
            'fields': ('user_prompt_display', 'prompt_template', 'variables_schema'),
        }),
        ('Metadata', {
            'fields': ('estimated_tokens', 'best_for', 'tags'),
        }),
        ('Status & Usage', {
            'fields': ('is_active', 'is_premium', 'usage_count'),
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
        }),
    )


@admin.register(WhisperSession)
class WhisperSessionAdmin(admin.ModelAdmin):
    """Admin interface for WhisperSession model"""
    list_display = ['id', 'user', 'template', 'status', 'created_at', 'completed_at']
    list_filter = ['status', 'created_at']
    search_fields = ['user__username', 'user__email', 'template__name']
    readonly_fields = ['id', 'created_at', 'updated_at']
    ordering = ['-created_at']

    fieldsets = (
        ('Session Info', {
            'fields': ('id', 'user', 'template', 'status'),
        }),
        ('Variables', {
            'fields': ('variables_input', 'variables_processed'),
        }),
        ('Output', {
            'fields': ('generated_prompt', 'error_message'),
        }),
        ('Timestamps', {
            'fields': ('created_at', 'completed_at', 'updated_at'),
        }),
    )


@admin.register(VoiceInput)
class VoiceInputAdmin(admin.ModelAdmin):
    """Admin interface for VoiceInput model"""
    list_display = ['id', 'session', 'variable_name', 'transcription_status', 'created_at']
    list_filter = ['transcription_status', 'created_at']
    search_fields = ['session__id', 'variable_name', 'transcribed_text']
    readonly_fields = ['id', 'created_at', 'updated_at']
    ordering = ['-created_at']


@admin.register(PromptHistory)
class PromptHistoryAdmin(admin.ModelAdmin):
    """Admin interface for PromptHistory model"""
    list_display = ['id', 'user', 'template_name', 'is_favorite', 'copy_count', 'created_at']
    list_filter = ['is_favorite', 'template_category', 'created_at']
    search_fields = ['user__username', 'template_name', 'full_prompt']
    readonly_fields = ['id', 'created_at', 'updated_at']
    ordering = ['-created_at']

    fieldsets = (
        ('Basic Info', {
            'fields': ('id', 'user', 'session', 'template_name', 'template_category'),
        }),
        ('Prompt Content', {
            'fields': ('prompt_preview', 'full_prompt', 'variables_used'),
        }),
        ('User Actions', {
            'fields': ('is_favorite', 'copy_count', 'last_copied_at'),
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
        }),
    )
