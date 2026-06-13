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
  }) async {
    final body = <String, dynamic>{
      'courseId': courseId,
      'dayNumber': dayNumber,
      'videoId': videoId,
    };
    final res = await _post('/api/mobile/progress/complete-session', body);
    return res as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> completeDay(
    String courseId,
    int dayNumber, {
    String? videoId,
  }) async {
    if (videoId != null) {
      return completeSession(courseId, dayNumber, videoId: videoId);
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

  Future<Map<String, dynamic>> getLeaderboard() async {
    final res = await _get('/api/mobile/leaderboard');
    return res as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final res = await _get('/api/mobile/profile');
    return res as Map<String, dynamic>;
  }

  Future<void> syncSteps(int steps, double calories) async {
    await _post('/api/mobile/steps', {'steps': steps, 'calories': calories});
  }

  Future<void> syncProfile({String? fullName, String? avatarUrl}) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
    await _post('/api/auth/sync', body);
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}
