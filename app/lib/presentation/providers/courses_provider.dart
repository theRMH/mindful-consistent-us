import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/api_service.dart';
import '../../data/models/course_model.dart';
import 'auth_provider.dart';

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

  List<CourseModel> get exploreCourses {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    return allCourses.where((c) {
      if (!enrolledCourseIds.contains(c.id)) return true;
      // Include expired enrollments so users can re-purchase the same course
      final enrollment = enrollmentForCourse(c.id);
      if (enrollment == null) return false;
      final enrolledAt = enrollment.enrolledAt.toLocal();
      final enrolledDate = DateTime(
        enrolledAt.year,
        enrolledAt.month,
        enrolledAt.day,
      );
      final calendarDay = todayDate.difference(enrolledDate).inDays + 1;
      return calendarDay > c.totalDays;
    }).toList();
  }

  EnrollmentModel? enrollmentForCourse(String courseId) {
    final matches = enrollments.where((e) => e.courseId == courseId);
    return matches.isEmpty ? null : matches.first;
  }

  bool get hasActiveCourse {
    if (enrollments.isEmpty) return false;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    for (final enrollment in enrollments) {
      final matches = allCourses.where((c) => c.id == enrollment.courseId);
      if (matches.isEmpty) continue;
      final course = matches.first;
      final enrolledAt = enrollment.enrolledAt.toLocal();
      final enrolledDate = DateTime(enrolledAt.year, enrolledAt.month, enrolledAt.day);
      final calendarDay = todayDate.difference(enrolledDate).inDays + 1;
      if (calendarDay <= course.totalDays) return true;
    }
    return false;
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
  final Ref _ref;

  CoursesNotifier(this._ref) : super(const CoursesState()) {
    _load();
    _ref.listen(authProvider, (prev, next) {
      if (prev?.isAuthenticated != next.isAuthenticated) {
        _load();
      }
    });
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final isAuth = _ref.read(authProvider).isAuthenticated;
      if (isAuth) {
        final token = await FirebaseAuth.instance.currentUser?.getIdToken();
        if (token != null) _apiService.setToken(token);
      }

      final results = await Future.wait([
        _apiService.getCourses().timeout(const Duration(seconds: 30)),
        if (isAuth)
          _apiService.getEnrollments().timeout(const Duration(seconds: 30)).catchError((_) => <dynamic>[])
        else
          Future<dynamic>.value(<dynamic>[]),
      ]);

      final courses = (results[0] as List<dynamic>)
          .map((e) => CourseModel.fromJson(e))
          .toList();
      final enrollmentList = (results[1] as List<dynamic>)
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
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => _load();
}

final coursesProvider = StateNotifierProvider<CoursesNotifier, CoursesState>((
  ref,
) {
  return CoursesNotifier(ref);
});
