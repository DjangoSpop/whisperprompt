import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String username;
  final String email;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'subscription_tier')
  final String subscriptionTier;
  @JsonKey(name: 'sessions_used_this_month')
  final int sessionsUsedThisMonth;
  @JsonKey(name: 'can_create_session')
  final bool canCreateSession;
  @JsonKey(name: 'date_joined')
  final DateTime dateJoined;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    required this.subscriptionTier,
    required this.sessionsUsedThisMonth,
    required this.canCreateSession,
    required this.dateJoined,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }

  bool get isPro => subscriptionTier == 'pro';
  bool get isFree => subscriptionTier == 'free';
}

@JsonSerializable()
class AuthTokens {
  final String access;
  final String refresh;

  AuthTokens({
    required this.access,
    required this.refresh,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
  Map<String, dynamic> toJson() => _$AuthTokensToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final User user;
  final String? message;

  AuthResponse({
    required this.user,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
