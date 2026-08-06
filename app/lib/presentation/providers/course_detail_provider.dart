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
  final String? instructorName;
  final String? instructorTitle;
  final String? instructorBio;
  final String? instructorPhotoUrl;
  final String? whatsappLink;
  final DateTime? scheduledStartDate;

  CourseDetail({
    required this.title,
    this.description,
    required this.totalDays,
    this.difficulty = 'Beginner',
    this.avgDailyMins = 30,
    required this.days,
    this.instructorName,
    this.instructorTitle,
    this.instructorBio,
    this.instructorPhotoUrl,
    this.whatsappLink,
    this.scheduledStartDate,
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
      instructorName: json['instructorName'] as String?,
      instructorTitle: json['instructorTitle'] as String?,
      instructorBio: json['instructorBio'] as String?,
      instructorPhotoUrl: json['instructorPhotoUrl'] as String?,
      whatsappLink: json['whatsappLink'] as String?,
      scheduledStartDate: json['scheduledStartDate'] != null
          ? DateTime.tryParse(json['scheduledStartDate'] as String)
          : null,
    );
  }
}

// In-memory cache — survives navigation, cleared on hot restart only.
final _cache = <String, CourseDetail>{};

// Not autoDispose — keeps data alive across navigation so returning to the
// same course is instant and never shows stale content from a previous fetch.
final courseDetailProvider =
    FutureProvider.family<CourseDetail, String>((ref, courseId) async {
  if (_cache.containsKey(courseId)) return _cache[courseId]!;
  final data = await ApiService().getCourseDetails(courseId);
  final detail = CourseDetail.fromJson(data);
  _cache[courseId] = detail;
  return detail;
});

/// Call this to force a fresh fetch (e.g. after admin edits content).
void invalidateCourseDetailCache(String courseId) => _cache.remove(courseId);
