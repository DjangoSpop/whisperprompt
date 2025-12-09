// GENERATED CODE - This file should be generated using build_runner
// Run: flutter pub run build_runner build

part of 'user.dart';

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      subscriptionTier: json['subscription_tier'] as String,
      sessionsUsedThisMonth: json['sessions_used_this_month'] as int,
      canCreateSession: json['can_create_session'] as bool,
      dateJoined: DateTime.parse(json['date_joined'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'subscription_tier': instance.subscriptionTier,
      'sessions_used_this_month': instance.sessionsUsedThisMonth,
      'can_create_session': instance.canCreateSession,
      'date_joined': instance.dateJoined.toIso8601String(),
    };

AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) => AuthTokens(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );

Map<String, dynamic> _$AuthTokensToJson(AuthTokens instance) => <String, dynamic>{
      'access': instance.access,
      'refresh': instance.refresh,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) => <String, dynamic>{
      'user': instance.user.toJson(),
      'message': instance.message,
    };
