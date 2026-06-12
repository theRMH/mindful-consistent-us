class CourseModel {
  final String id;
  final String title;
  final String slug;
  final String? description;
  final String? thumbnailUrl;
  final String? category; // 'yoga' | 'general_exercise'
  final int totalDays;
  final double priceInr;

  const CourseModel({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.thumbnailUrl,
    this.category,
    required this.totalDays,
    required this.priceInr,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      category: json['category'] as String?,
      totalDays: json['totalDays'] as int,
      priceInr: double.parse(json['priceInr']?.toString() ?? '0'),
    );
  }
}

class EnrollmentModel {
  final String id;
  final String courseId;
  final bool isActive;
  final DateTime enrolledAt;

  const EnrollmentModel({
    required this.id,
    required this.courseId,
    required this.isActive,
    required this.enrolledAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      isActive: json['isActive'] as bool? ?? true,
      enrolledAt: DateTime.parse(json['enrolledAt'] as String),
    );
  }
}

class VideoModel {
  final String id;
  final String title;
  final String videoSource; // 'youtube' | 'bunny'
  final String? youtubeVideoId;
  final String? bunnyVideoId;
  final String? bunnyLibraryId;
  final String? thumbnailUrl;
  final int durationSeconds;
  final String? category;

  const VideoModel({
    required this.id,
    required this.title,
    required this.videoSource,
    this.youtubeVideoId,
    this.bunnyVideoId,
    this.bunnyLibraryId,
    this.thumbnailUrl,
    required this.durationSeconds,
    this.category,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      videoSource: json['videoSource'] as String? ?? 'bunny',
      youtubeVideoId: json['youtubeVideoId'] as String?,
      bunnyVideoId: json['bunnyVideoId'] as String?,
      bunnyLibraryId: json['bunnyLibraryId'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      category: json['category'] as String?,
    );
  }
}

class FreeVideoModel {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final int durationSeconds;
  final String videoSource;
  final String? youtubeVideoId;
  final String? bunnyVideoId;
  final String? bunnyLibraryId;
  final String? thumbnailUrl;

  const FreeVideoModel({
    required this.id,
    required this.title,
    this.description,
    this.category,
    required this.durationSeconds,
    required this.videoSource,
    this.youtubeVideoId,
    this.bunnyVideoId,
    this.bunnyLibraryId,
    this.thumbnailUrl,
  });

  String get durationLabel {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  factory FreeVideoModel.fromJson(Map<String, dynamic> json) {
    return FreeVideoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      videoSource: json['videoSource'] as String? ?? 'bunny',
      youtubeVideoId: json['youtubeVideoId'] as String?,
      bunnyVideoId: json['bunnyVideoId'] as String?,
      bunnyLibraryId: json['bunnyLibraryId'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }
}

class CourseDayModel {
  final String id;
  final int dayNumber;
  final String? title;
  final String? description;
  final List<VideoModel> videos;

  const CourseDayModel({
    required this.id,
    required this.dayNumber,
    this.title,
    this.description,
    required this.videos,
  });

  factory CourseDayModel.fromJson(Map<String, dynamic> json) {
    final videosList = (json['videos'] as List<dynamic>?)
            ?.map((v) => VideoModel.fromJson(v as Map<String, dynamic>))
            .toList() ??
        [];
    return CourseDayModel(
      id: json['id'] as String,
      dayNumber: json['dayNumber'] as int,
      title: json['title'] as String?,
      description: json['description'] as String?,
      videos: videosList,
    );
  }
}
