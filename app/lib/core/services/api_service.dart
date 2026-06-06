import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Simple token storage for mock/demo auth
  String? _authToken = 'mock-user-123';

  void setToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
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
        throw HttpException('API Error: ${response.statusCode} - ${response.body}');
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
        throw HttpException('API Error: ${response.statusCode} - ${response.body}');
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

  Future<Map<String, dynamic>> completeDay(String courseId, int dayNumber) async {
    final res = await _post('/api/mobile/progress/complete-day', {
      'courseId': courseId,
      'dayNumber': dayNumber,
    });
    return res as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> simulateProgress(Map<String, dynamic> params) async {
    final res = await _post('/api/mobile/progress/simulate', params);
    return res as Map<String, dynamic>;
  }

  Future<List<dynamic>> getLeaderboard() async {
    final res = await _get('/api/mobile/leaderboard');
    return res as List<dynamic>;
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}
