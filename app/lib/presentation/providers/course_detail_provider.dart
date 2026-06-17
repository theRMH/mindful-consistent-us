import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../../data/models/course_model.dart';

class CourseDetail {
  final String title;
  final String? description;
  final int totalDays;
  final String difficulty;
  final int avgDailyMins;
  final List<CourseDayModel> days;

  CourseDetail({
    required this.title,
    this.description,
    required this.totalDays,
    this.difficulty = 'Beginner',
    this.avgDailyMins = 30,
    required this.days,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    final daysList = (json['courseDays'] as List<dynamic>?)
            ?.map((d) => CourseDayModel.fromJson(d as Map<String, dynamic>))
            .toList() ??
        [];
    return CourseDetail(
      title: json['title'] as String,
      description: json['description'] as String?,
      totalDays: json['totalDays'] as int,
      difficulty: json['difficulty'] as String? ?? 'Beginner',
      avgDailyMins: (json['avgDailyMins'] as num?)?.toInt() ?? 30,
      days: daysList,
    );
  }
}

final courseDetailProvider =
    FutureProvider.autoDispose.family<CourseDetail, String>((ref, courseId) async {
  final api = ApiService();
  final data = await api.getCourseDetails(courseId);
  return CourseDetail.fromJson(data);
});
