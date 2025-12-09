/// API Configuration
class ApiConfig {
  // Base URLs
  static const String prodBaseUrl = 'https://api.aiwhisperer.app';
  static const String devBaseUrl = 'http://localhost:8000';

  // Current environment
  static const bool isProduction = bool.fromEnvironment(
    'dart.vm.product',
    defaultValue: false,
  );

  // Get base URL based on environment
  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;

  // API Version
  static const String apiVersion = 'v1';

  // Full API URL
  static String get apiUrl => '$baseUrl/api/$apiVersion';

  // Endpoints
  static const String authRegister = '/auth/register/';
  static const String authLogin = '/auth/login/';
  static const String authRefresh = '/auth/refresh/';
  static const String authProfile = '/auth/profile/';

  static const String categories = '/categories/';
  static String category(String slug) => '/categories/$slug/';

  static const String templates = '/templates/';
  static String template(String slug) => '/templates/$slug/';

  static const String sessions = '/sessions/';
  static String session(String id) => '/sessions/$id/';
  static String sessionVoice(String id) => '/sessions/$id/voice/';
  static String sessionStatus(String id) => '/sessions/$id/status/';
  static String sessionGenerate(String id) => '/sessions/$id/generate/';

  static const String history = '/history/';
  static String historyItem(String id) => '/history/$id/';
  static String historyCopy(String id) => '/history/$id/copy/';
  static String historyFavorite(String id) => '/history/$id/favorite/';
  static const String historyStats = '/history/stats/';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 60);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
}
