import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/template.dart';
import '../models/session.dart';
import '../models/history.dart';
import 'storage_service.dart';

class ApiService {
  late final Dio _dio;
  final StorageService _storageService;

  ApiService(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.apiUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token
          final token = await _storageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Try to refresh token
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the request
              final options = error.requestOptions;
              final token = await _storageService.getAccessToken();
              options.headers['Authorization'] = 'Bearer $token';
              try {
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Add logger in debug mode
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );
  }

  // ========== Authentication ==========

  Future<AuthTokens> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    String? firstName,
    String? lastName,
  }) async {
    final response = await _dio.post(
      ApiConfig.authRegister,
      data: {
        'username': username,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
      },
    );

    // The registration might return user + message, need to login separately
    return await login(username: username, password: password);
  }

  Future<AuthTokens> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConfig.authLogin,
      data: {
        'username': username,
        'password': password,
      },
    );

    final tokens = AuthTokens.fromJson(response.data);
    await _storageService.saveTokens(tokens);
    return tokens;
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiConfig.authRefresh,
        data: {'refresh': refreshToken},
      );

      final newAccessToken = response.data['access'] as String;
      await _storageService.saveAccessToken(newAccessToken);
      return true;
    } catch (e) {
      await _storageService.clearTokens();
      return false;
    }
  }

  Future<User> getProfile() async {
    final response = await _dio.get(ApiConfig.authProfile);
    return User.fromJson(response.data);
  }

  Future<void> logout() async {
    await _storageService.clearAll();
  }

  // ========== Templates ==========

  Future<List<TemplateCategory>> getCategories() async {
    final response = await _dio.get(ApiConfig.categories);
    return (response.data as List)
        .map((json) => TemplateCategory.fromJson(json))
        .toList();
  }

  Future<TemplateCategory> getCategory(String slug) async {
    final response = await _dio.get(ApiConfig.category(slug));
    return TemplateCategory.fromJson(response.data);
  }

  Future<List<PromptTemplate>> getTemplates({String? categorySlug}) async {
    final response = await _dio.get(
      ApiConfig.templates,
      queryParameters: categorySlug != null ? {'category': categorySlug} : null,
    );
    return (response.data as List)
        .map((json) => PromptTemplate.fromJson(json))
        .toList();
  }

  Future<PromptTemplateDetail> getTemplate(String slug) async {
    final response = await _dio.get(ApiConfig.template(slug));
    return PromptTemplateDetail.fromJson(response.data);
  }

  // ========== Sessions ==========

  Future<WhisperSession> createSession(String templateSlug) async {
    final response = await _dio.post(
      ApiConfig.sessions,
      data: {'template_slug': templateSlug},
    );
    return WhisperSession.fromJson(response.data);
  }

  Future<VoiceInput> uploadVoice({
    required String sessionId,
    required String variableName,
    required String audioFilePath,
    int? audioDurationMs,
  }) async {
    final formData = FormData.fromMap({
      'variable_name': variableName,
      'audio_file': await MultipartFile.fromFile(audioFilePath),
      if (audioDurationMs != null) 'audio_duration_ms': audioDurationMs,
    });

    final response = await _dio.post(
      ApiConfig.sessionVoice(sessionId),
      data: formData,
    );

    return VoiceInput.fromJson(response.data);
  }

  Future<SessionStatus> getSessionStatus(String sessionId) async {
    final response = await _dio.get(ApiConfig.sessionStatus(sessionId));
    return SessionStatus.fromJson(response.data);
  }

  Future<GeneratePromptResponse> generatePrompt(String sessionId) async {
    final response = await _dio.post(ApiConfig.sessionGenerate(sessionId));
    return GeneratePromptResponse.fromJson(response.data);
  }

  Future<List<WhisperSession>> getSessions() async {
    final response = await _dio.get(ApiConfig.sessions);
    return (response.data as List)
        .map((json) => WhisperSession.fromJson(json))
        .toList();
  }

  Future<WhisperSession> getSession(String sessionId) async {
    final response = await _dio.get(ApiConfig.session(sessionId));
    return WhisperSession.fromJson(response.data);
  }

  // ========== History ==========

  Future<List<PromptHistory>> getHistory({
    bool? favoritesOnly,
    String? category,
  }) async {
    final response = await _dio.get(
      ApiConfig.history,
      queryParameters: {
        if (favoritesOnly != null && favoritesOnly) 'favorites': 'true',
        if (category != null) 'category': category,
      },
    );
    return (response.data as List)
        .map((json) => PromptHistory.fromJson(json))
        .toList();
  }

  Future<PromptHistoryDetail> getHistoryItem(String historyId) async {
    final response = await _dio.get(ApiConfig.historyItem(historyId));
    return PromptHistoryDetail.fromJson(response.data);
  }

  Future<void> trackCopy(String historyId) async {
    await _dio.post(ApiConfig.historyCopy(historyId));
  }

  Future<void> toggleFavorite(String historyId) async {
    await _dio.patch(ApiConfig.historyFavorite(historyId));
  }

  Future<HistoryStats> getHistoryStats() async {
    final response = await _dio.get(ApiConfig.historyStats);
    return HistoryStats.fromJson(response.data);
  }
}
