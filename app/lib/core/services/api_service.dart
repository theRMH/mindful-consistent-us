import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  void setToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<dynamic> _get(String path) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}$path');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw HttpException(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }

  Future<dynamic> _put(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}$path');
    try {
      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw HttpException(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}$path');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw HttpException(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }

  // --- API Endpoints ---

  Future<List<dynamic>> getCourses() async {
    final res = await _get('/api/mobile/courses');
    return res as List<dynamic>;
  }

  Future<Map<String, dynamic>> getCourseDetails(String courseId) async {
    final res = await _get('/api/mobile/courses/$courseId');
    return res as Map<String, dynamic>;
  }

  Future<List<dynamic>> getFreeVideos() async {
    final res = await _get('/api/mobile/free-videos');
    return res as List<dynamic>;
  }

  Future<List<dynamic>> getCommunityMoments() async {
    final res = await _get('/api/mobile/community-moments');
    return res as List<dynamic>;
  }

  Future<List<dynamic>> getEnrollments() async {
    final res = await _get('/api/mobile/enrollments');
    return res as List<dynamic>;
  }

  Future<Map<String, dynamic>> enrollInCourse(String courseId) async {
    final res = await _post('/api/mobile/enrollments', {'courseId': courseId});
    return res as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProgress() async {
    final res = await _get('/api/mobile/progress');
    return res as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> completeSession(
    String courseId,
    int dayNumber, {
    required String videoId,
    int? todaySteps,
  }) async {
    final body = <String, dynamic>{
      'courseId': courseId,
      'dayNumber': dayNumber,
      'videoId': videoId,
      'todaySteps': todaySteps,
    };
    final res = await _post('/api/mobile/progress/complete-session', body);
    return res as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> completeDay(
    String courseId,
    int dayNumber, {
    String? videoId,
    int? todaySteps,
  }) async {
    if (videoId != null) {
      return completeSession(courseId, dayNumber, videoId: videoId, todaySteps: todaySteps);
    }
    final res = await _post('/api/mobile/progress/complete-day', {
      'courseId': courseId,
      'dayNumber': dayNumber,
    });
    return res as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> simulateProgress(
    Map<String, dynamic> params,
  ) async {
    final res = await _post('/api/mobile/progress/simulate', params);
    return res as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getLeaderboard({String? courseId}) async {
    final path = courseId != null
        ? '/api/mobile/leaderboard?courseId=$courseId'
        : '/api/mobile/leaderboard';
    final res = await _get(path);
    return res as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final res = await _get('/api/mobile/profile');
    return res as Map<String, dynamic>;
  }

  Future<void> syncSteps(int steps, double calories) async {
    await _post('/api/mobile/steps', {'steps': steps, 'calories': calories});
  }

  Future<void> saveDailySteps(String dateStr, int steps) async {
    await _post('/api/mobile/steps/history', {'dateStr': dateStr, 'steps': steps});
  }

  Future<List<Map<String, dynamic>>> getDailyStepHistory() async {
    final res = await _get('/api/mobile/steps/history');
    return (res as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<void> syncProfile({String? fullName, String? avatarUrl}) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
    await _post('/api/auth/sync', body);
  }

  Future<List<dynamic>> getBodyMetrics() async {
    final res = await _get('/api/mobile/profile/body-metrics');
    return (res as Map<String, dynamic>)['records'] as List<dynamic>;
  }

  Future<void> saveBodyMetrics({
    String? courseId,
    String? name,
    int? age,
    double? heightCm,
    double? weightKg,
    double? waistIn,
    double? hipIn,
  }) async {
    final body = <String, dynamic>{};
    if (courseId != null) body['courseId'] = courseId;
    if (name != null) body['name'] = name;
    if (age != null) body['age'] = age;
    if (heightCm != null) body['heightCm'] = heightCm;
    if (weightKg != null) body['weightKg'] = weightKg;
    if (waistIn != null) body['waistIn'] = waistIn;
    if (hipIn != null) body['hipIn'] = hipIn;
    await _post('/api/mobile/profile/body-metrics', body);
  }

  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
    bool? notificationsEnabled,
    String? notificationTime,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
    if (notificationsEnabled != null) body['notificationsEnabled'] = notificationsEnabled;
    if (notificationTime != null) body['notificationTime'] = notificationTime;
    await _put('/api/mobile/profile', body);
  }

  Future<void> updateFcmToken(String token) async {
    await _post('/api/mobile/fcm-token', {'token': token});
  }

  Future<List<dynamic>> getNotifications() async {
    final res = await _get('/api/mobile/notifications');
    return res as List<dynamic>;
  }

  Future<void> markNotificationRead(String id) async {
    await _post('/api/mobile/notifications/$id', {});
  }

  Future<String> getHelpContent() async {
    final res = await _get('/api/help-content');
    return (res as Map<String, dynamic>)['content'] as String? ?? '';
  }

  Future<bool> submitFeedback({
    required int rating,
    required String comment,
  }) async {
    try {
      await _post('/api/feedback', {
        'targetType': 'course',
        'rating': rating,
        'comment': comment,
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}
