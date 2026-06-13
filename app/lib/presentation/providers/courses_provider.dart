import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/services/api_service.dart';
import '../../data/models/course_model.dart';

class CoursesState {
  final List<CourseModel> allCourses;
  final Set<String> enrolledCourseIds;
  final List<EnrollmentModel> enrollments;
  final bool isLoading;
  final String? error;

  const CoursesState({
    this.allCourses = const [],
    this.enrolledCourseIds = const {},
    this.enrollments = const [],
    this.isLoading = false,
    this.error,
  });

  List<CourseModel> get activeCourses =>
      allCourses.where((c) => enrolledCourseIds.contains(c.id)).toList();

  List<CourseModel> get exploreCourses =>
      allCourses.where((c) => !enrolledCourseIds.contains(c.id)).toList();

  EnrollmentModel? enrollmentForCourse(String courseId) {
    final matches = enrollments.where((e) => e.courseId == courseId);
    return matches.isEmpty ? null : matches.first;
  }

  CoursesState copyWith({
    List<CourseModel>? allCourses,
    Set<String>? enrolledCourseIds,
    List<EnrollmentModel>? enrollments,
    bool? isLoading,
    String? error,
  }) {
    return CoursesState(
      allCourses: allCourses ?? this.allCourses,
      enrolledCourseIds: enrolledCourseIds ?? this.enrolledCourseIds,
      enrollments: enrollments ?? this.enrollments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CoursesNotifier extends StateNotifier<CoursesState> {
  final ApiService _apiService = ApiService();

  CoursesNotifier() : super(const CoursesState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    debugPrint('[Courses] Loading from ${AppConfig.apiBaseUrl}');
    try {
      final coursesData = await _apiService
          .getCourses()
          .timeout(const Duration(seconds: 10));

      debugPrint('[Courses] Loaded ${coursesData.length} courses');

      List<dynamic> enrollmentsData = [];
      try {
        enrollmentsData = await _apiService
            .getEnrollments()
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('[Courses] Enrollments skipped (no auth): $e');
      }

      final courses = coursesData
          .map((e) => CourseModel.fromJson(e))
          .toList();

      final enrollmentList = enrollmentsData
          .map((e) => EnrollmentModel.fromJson(e))
          .toList();

      final enrolledIds = enrollmentList.map((e) => e.courseId).toSet();

      state = state.copyWith(
        allCourses: courses,
        enrolledCourseIds: enrolledIds,
        enrollments: enrollmentList,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[Courses] ERROR: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> enroll(String courseId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // MOCK: Add directly to enrolledCourseIds without relying on backend
      final newEnrolled = Set<String>.from(state.enrolledCourseIds)..add(courseId);
      
      // Also mock an EnrollmentModel so it shows up correctly
      final newEnrollments = List<EnrollmentModel>.from(state.enrollments);
      if (!newEnrollments.any((e) => e.courseId == courseId)) {
        newEnrollments.add(EnrollmentModel(
          id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
          courseId: courseId,
          isActive: true,
          enrolledAt: DateTime.now(),
        ));
      }
      
      state = state.copyWith(
        enrolledCourseIds: newEnrolled,
        enrollments: newEnrollments,
        isLoading: false,
      );
      
      // Attempt API call but ignore errors
      try {
        await _apiService.enrollInCourse(courseId);
      } catch (_) {}
      
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => _load();
}

final coursesProvider =
    StateNotifierProvider<CoursesNotifier, CoursesState>((ref) {
  return CoursesNotifier();
});
