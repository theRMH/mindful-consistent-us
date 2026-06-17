import 'package:health/health.dart';
import 'api_service.dart';

class HealthSyncService {
  static final HealthSyncService _instance = HealthSyncService._internal();
  factory HealthSyncService() => _instance;
  HealthSyncService._internal();

  final Health _health = Health();

  static const _types = [HealthDataType.STEPS];

  /// Returns null if Health Connect / HealthKit is not available on this device.
  /// Returns true if permissions are granted, false if denied.
  Future<bool?> requestAuthorization() async {
    try {
      if (!await _isAvailable()) return null;
      return await _health.requestAuthorization(_types);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _isAvailable() async {
    try {
      final status = await _health.getHealthConnectSdkStatus();
      return status == HealthConnectSdkStatus.sdkAvailable;
    } catch (_) {
      return false;
    }
  }

  /// Read today's step total from the platform health store and sync to the
  /// backend. Returns the step count, or null on failure.
  Future<int?> syncTodaySteps() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final authorized = await _health.requestAuthorization(_types);
      if (!authorized) return null;

      final total = await _health.getTotalStepsInInterval(midnight, now);
      if (total == null) return null;

      final calories = total * 0.0496;
      await ApiService().syncSteps(total, calories);
      return total;
    } catch (_) {
      return null;
    }
  }
}
