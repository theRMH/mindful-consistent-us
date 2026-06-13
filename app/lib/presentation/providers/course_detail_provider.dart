import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../../data/models/course_model.dart';

class CourseDetail {
  final String title;
  final int totalDays;
  final List<CourseDayModel> days;

  CourseDetail({
    required this.title,
    required this.totalDays,
    required this.days,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    final daysList = (json['courseDays'] as List<dynamic>?)
            ?.map((d) => CourseDayModel.fromJson(d as Map<String, dynamic>))
            .toList() ??
        [];
    return CourseDetail(
      title: json['title'] as String,
      totalDays: json['totalDays'] as int,
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
