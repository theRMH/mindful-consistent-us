import 'dart:async';
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
  StreamSubscription<User?>? _tokenSub;
  bool _enrollmentsLoaded = false;

  CoursesNotifier(this._ref) : super(const CoursesState()) {
    _init();
  }

  Future<void> _init() async {
    // Load public courses immediately (no auth needed)
    _loadCourses();

    // Wait for a valid Firebase token before loading enrollments
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await _loadEnrollments(currentUser);
    }

    // Also listen for token changes (covers the case where Firebase
    // is not fully ready at construction time)
    _tokenSub = FirebaseAuth.instance.idTokenChanges().listen((user) async {
      if (user != null && !_enrollmentsLoaded) {
        await _loadEnrollments(user);
      } else if (user == null) {
        _enrollmentsLoaded = false;
        state = state.copyWith(enrolledCourseIds: {}, enrollments: []);
      }
    });

    // Re-load when auth state changes (login/logout)
    _ref.listen(authProvider, (prev, next) {
      if (prev?.isAuthenticated != next.isAuthenticated) {
        _enrollmentsLoaded = false;
        if (next.isAuthenticated) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) _loadEnrollments(user);
        } else {
          state = state.copyWith(enrolledCourseIds: {}, enrollments: []);
        }
      }
    });
  }

  Future<void> _loadCourses() async {
    try {
      final raw = await _apiService.getCourses().timeout(const Duration(seconds: 30));
      final courses = raw.map((e) => CourseModel.fromJson(e as Map<String, dynamic>)).toList();
      state = state.copyWith(allCourses: courses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _loadEnrollments(User user) async {
    try {
      final token = await user.getIdToken();
      if (token != null) _apiService.setToken(token);
      final raw = await _apiService.getEnrollments().timeout(const Duration(seconds: 30));
      final enrollmentList = raw.map((e) => EnrollmentModel.fromJson(e as Map<String, dynamic>)).toList();
      final enrolledIds = enrollmentList.map((e) => e.courseId).toSet();
      _enrollmentsLoaded = true;
      state = state.copyWith(enrolledCourseIds: enrolledIds, enrollments: enrollmentList, isLoading: false);
    } catch (e) {
      // Enrollment fetch failure should not redirect — keep empty list
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _load() async {
    _enrollmentsLoaded = false;
    state = state.copyWith(isLoading: true);
    await _loadCourses();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) await _loadEnrollments(user);
  }

  Future<void> refresh() => _load();

  @override
  void dispose() {
    _tokenSub?.cancel();
    super.dispose();
  }
}

final coursesProvider = StateNotifierProvider<CoursesNotifier, CoursesState>((
  ref,
) {
  return CoursesNotifier(ref);
});
