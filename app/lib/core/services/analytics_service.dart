import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  final _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> setUser(String uid) => _analytics.setUserId(id: uid);

  Future<void> logLogin() => _analytics.logLogin(loginMethod: 'phone_otp');

  Future<void> logSignUp() => _analytics.logSignUp(signUpMethod: 'phone_otp');

  Future<void> logVideoStart(String title) => _analytics.logEvent(
        name: 'video_start',
        parameters: {'video_title': title},
      );

  Future<void> logVideoComplete(String title) => _analytics.logEvent(
        name: 'video_complete',
        parameters: {'video_title': title},
      );

  Future<void> logSessionComplete(String courseId, int dayNumber) =>
      _analytics.logEvent(
        name: 'session_complete',
        parameters: {'course_id': courseId, 'day_number': dayNumber},
      );

  Future<void> logPurchase({
    required String courseId,
    required String courseTitle,
    required int amountPaid,
  }) =>
      _analytics.logPurchase(
        currency: 'INR',
        value: amountPaid.toDouble(),
        items: [
          AnalyticsEventItem(
            itemId: courseId,
            itemName: courseTitle,
          ),
        ],
      );
}
