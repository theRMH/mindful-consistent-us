import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';
import '../../core/config/app_config.dart';
import 'auth_provider.dart';

class LeaderboardUser {
  final int rank;
  final String name;
  final String avatarUrl;
  final int streak;
  final int score;
  final bool isCurrentUser;

  LeaderboardUser({
    required this.rank,
    required this.name,
    required this.avatarUrl,
    required this.streak,
    required this.score,
    required this.isCurrentUser,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      rank: json['rank'] ?? 0,
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      streak: json['streak'] ?? 0,
      score: (json['score'] as num?)?.toInt() ?? 0,
      isCurrentUser: json['isCurrentUser'] ?? false,
    );
  }
}

class ProgressState {
  final int steps;
  final double calories;
  final int mindfulMins;
  final int currentStreak;
  final int completedSessionsToday;
  final int totalSessionsToday;
  final List<int> completedDays; // e.g. [1, 2, 4]
  final List<String> completedVideoIds;
  final List<LeaderboardUser> leaderboard;
  final String? activeCourseId;
  final int? currentDay;
  final int? userRank;

  final List<Map<String, dynamic>> weeklyActivity;
  final int stepsGoal;
  final bool isLoading;
  final String? error;

  ProgressState({
    this.steps = 0,
    this.calories = 0.0,
    this.mindfulMins = 0,
    this.currentStreak = 0,
    this.completedSessionsToday = 0,
    this.totalSessionsToday = 0,
    this.completedDays = const [],
    this.completedVideoIds = const [],
    this.leaderboard = const [],
    this.activeCourseId,
    this.currentDay,
    this.userRank,
    this.weeklyActivity = const [
      {'label': 'M', 'val': 0},
      {'label': 'T', 'val': 0},
      {'label': 'W', 'val': 0},
      {'label': 'T', 'val': 0},
      {'label': 'F', 'val': 0},
      {'label': 'S', 'val': 0},
      {'label': 'S', 'val': 0},
    ],
    this.stepsGoal = 10000,
    this.isLoading = false,
    this.error,
  });

  ProgressState copyWith({
    int? steps,
    double? calories,
    int? mindfulMins,
    int? currentStreak,
    int? completedSessionsToday,
    int? totalSessionsToday,
    List<int>? completedDays,
    List<String>? completedVideoIds,
    List<LeaderboardUser>? leaderboard,
    String? activeCourseId,
    int? currentDay,
    int? userRank,
    List<Map<String, dynamic>>? weeklyActivity,
    int? stepsGoal,
    bool? isLoading,
    String? error,
  }) {
    return ProgressState(
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      mindfulMins: mindfulMins ?? this.mindfulMins,
      currentStreak: currentStreak ?? this.currentStreak,
      completedSessionsToday:
          completedSessionsToday ?? this.completedSessionsToday,
      totalSessionsToday: totalSessionsToday ?? this.totalSessionsToday,
      completedDays: completedDays ?? this.completedDays,
      completedVideoIds: completedVideoIds ?? this.completedVideoIds,
      leaderboard: leaderboard ?? this.leaderboard,
      activeCourseId: activeCourseId ?? this.activeCourseId,
      currentDay: currentDay ?? this.currentDay,
      userRank: userRank ?? this.userRank,
      weeklyActivity: weeklyActivity ?? this.weeklyActivity,
      stepsGoal: stepsGoal ?? this.stepsGoal,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProgressNotifier extends StateNotifier<ProgressState> {
  final ApiService _apiService = ApiService();
  final Ref _ref;

  ProgressNotifier(this._ref) : super(ProgressState()) {
    loadInitialData();
    _ref.listen(authProvider, (prev, next) {
      if (prev?.isAuthenticated != next.isAuthenticated) {
        refreshFromApi();
      }
    });
  }

  Future<void> loadInitialData() async {
    await refreshFromApi();
  }

  Future<void> _loadGuestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final lastOpened = prefs.getString('guest_last_opened_date');
    int streak = prefs.getInt('guest_streak') ?? 0;

    if (lastOpened == null) {
      streak = 1;
    } else if (lastOpened != todayStr) {
      final last = DateTime.parse(lastOpened);
      final diff = DateTime(
        today.year,
        today.month,
        today.day,
      ).difference(DateTime(last.year, last.month, last.day)).inDays;
      streak = diff == 1 ? streak + 1 : 1;
    }

    await prefs.setString('guest_last_opened_date', todayStr);
    await prefs.setInt('guest_streak', streak);
    state = state.copyWith(currentStreak: streak, isLoading: false);
  }

  Future<void> refreshFromApi() async {
    if (!_ref.read(authProvider).isAuthenticated) {
      await _loadGuestStreak();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _apiService.getProgress(),
        _apiService.getLeaderboard(),
        _apiService.getProfile(),
      ]);
      final progressData = results[0];
      final leaderboardData = results[1];
      final profileData = results[2];

      final stats = progressData['stats'] ?? {};
      final compDays = List<int>.from(progressData['completedDays'] ?? []);
      final compVideoIds = List<String>.from(
        progressData['completedVideoIds'] ?? [],
      );
      final weeklyRaw =
          progressData['weeklyActivity'] as List<dynamic>? ?? [];
      final weeklyActivity = weeklyRaw
          .map((e) => {
                'label': (e as Map<String, dynamic>)['label'] as String,
                'val': (e['val'] as num).toInt(),
              })
          .toList();

      final leaderboardEntries =
          leaderboardData['entries'] as List<dynamic>? ?? [];
      final leaderboardList = leaderboardEntries
          .map((item) => LeaderboardUser.fromJson(item as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        steps: stats['totalSteps'] ?? 0,
        calories: (stats['totalCalories'] as num?)?.toDouble() ?? 0.0,
        mindfulMins: stats['mindfulMins'] ?? 0,
        currentStreak: stats['currentStreak'] ?? 0,
        completedSessionsToday: stats['totalSessions'] ?? 0,
        completedDays: compDays,
        completedVideoIds: compVideoIds,
        leaderboard: leaderboardList,
        activeCourseId: progressData['activeCourseId'] as String?,
        currentDay: (progressData['currentDayNumber'] as num?)?.toInt(),
        userRank: leaderboardData['userRank'] as int?,
        weeklyActivity: weeklyActivity,
        stepsGoal: (profileData['stepsGoal'] as num?)?.toInt() ?? 10000,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // --- Real / Mock Mutators ---

  Future<void> addSteps(int increment) async {
    if (AppConfig.useMockData) {
      final newSteps = state.steps + increment;
      final newCalories = newSteps * 0.04;
      state = state.copyWith(steps: newSteps, calories: newCalories);
      _updateMockLeaderboardScore();
    } else {
      state = state.copyWith(isLoading: true);
      try {
        await _apiService.simulateProgress({'steps': increment});
        await refreshFromApi();
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> addMindfulMinutes(int minutes) async {
    if (AppConfig.useMockData) {
      state = state.copyWith(mindfulMins: state.mindfulMins + minutes);
      _updateMockLeaderboardScore();
    } else {
      state = state.copyWith(isLoading: true);
      try {
        await _apiService.simulateProgress({'mindfulMins': minutes});
        await refreshFromApi();
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> completeSession() async {
    if (AppConfig.useMockData) {
      final nextSessionCount = state.completedSessionsToday + 1;
      state = state.copyWith(
        completedSessionsToday: nextSessionCount > state.totalSessionsToday
            ? state.totalSessionsToday
            : nextSessionCount,
      );
    } else {
      // Incremented automatically when completing a day/video
    }
  }

  Future<void> markDayComplete(
    int dayNumber, {
    String courseId = '',
    String? videoId,
    int? todaySteps,
  }) async {
    if (AppConfig.useMockData) {
      if (!state.completedDays.contains(dayNumber)) {
        final updatedDays = List<int>.from(state.completedDays)..add(dayNumber);
        updatedDays.sort();
        final newStreak = state.currentStreak + 1;
        state = state.copyWith(
          completedDays: updatedDays,
          currentStreak: newStreak,
        );
        _updateMockLeaderboardScore();
      }
    } else {
      state = state.copyWith(isLoading: true);
      try {
        await _apiService.completeDay(courseId, dayNumber, videoId: videoId, todaySteps: todaySteps);
        await refreshFromApi();
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> enrollCourse(String courseId) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
    } else {
      state = state.copyWith(isLoading: true);
      try {
        await _apiService.enrollInCourse(courseId);
        await refreshFromApi();
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  // --- Developer Simulation Dials ---

  Future<void> simulateStreak(int targetStreak) async {
    if (AppConfig.useMockData) {
      state = state.copyWith(currentStreak: targetStreak);
      _updateMockLeaderboardScore();
    } else {
      state = state.copyWith(isLoading: true);
      try {
        await _apiService.simulateProgress({'streak': targetStreak});
        await refreshFromApi();
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> simulateDayCompletion(int dayNumber) async {
    if (AppConfig.useMockData) {
      final updatedDays = List<int>.from(state.completedDays);
      if (updatedDays.contains(dayNumber)) {
        updatedDays.remove(dayNumber);
      } else {
        updatedDays.add(dayNumber);
      }
      updatedDays.sort();
      state = state.copyWith(completedDays: updatedDays);
      _updateMockLeaderboardScore();
    } else {
      state = state.copyWith(isLoading: true);
      try {
        await _apiService.simulateProgress({'completedDay': dayNumber});
        await refreshFromApi();
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> simulateScore(int targetScore) async {
    if (AppConfig.useMockData) {
      final updatedLeaderboard = state.leaderboard.map((user) {
        if (user.isCurrentUser) {
          return LeaderboardUser(
            rank: user.rank,
            name: user.name,
            avatarUrl: user.avatarUrl,
            streak: user.streak,
            score: targetScore,
            isCurrentUser: true,
          );
        }
        return user;
      }).toList();
      _resortLeaderboard(updatedLeaderboard);
    } else {
      state = state.copyWith(isLoading: true);
      try {
        await _apiService.simulateProgress({'score': targetScore});
        await refreshFromApi();
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> resetProgress() async {
    if (AppConfig.useMockData) {
      state = ProgressState(
        steps: 0,
        calories: 0.0,
        mindfulMins: 0,
        currentStreak: 0,
        completedSessionsToday: 0,
        completedDays: [],
        leaderboard: [
          LeaderboardUser(
            rank: 1,
            name: 'Priya S',
            avatarUrl: 'assets/avatar_priya.png',
            streak: 12,
            score: 1420,
            isCurrentUser: false,
          ),
          LeaderboardUser(
            rank: 2,
            name: 'Rohit K',
            avatarUrl: 'assets/avatar_rohit.png',
            streak: 8,
            score: 980,
            isCurrentUser: false,
          ),
          LeaderboardUser(
            rank: 3,
            name: 'You',
            avatarUrl: '',
            streak: 0,
            score: 0,
            isCurrentUser: true,
          ),
        ],
      );
    } else {
      state = state.copyWith(isLoading: true);
      try {
        await _apiService.simulateProgress({'action': 'reset'});
        await refreshFromApi();
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  // --- Helper Methods ---

  void _updateMockLeaderboardScore() {
    // Score formula = days completed * 100 + streak * 10
    final calculatedScore =
        state.completedDays.length * 100 + state.currentStreak * 10;
    final updatedLeaderboard = state.leaderboard.map((user) {
      if (user.isCurrentUser) {
        return LeaderboardUser(
          rank: user.rank,
          name: user.name,
          avatarUrl: user.avatarUrl,
          streak: state.currentStreak,
          score: calculatedScore,
          isCurrentUser: true,
        );
      }
      return user;
    }).toList();
    _resortLeaderboard(updatedLeaderboard);
  }

  void _resortLeaderboard(List<LeaderboardUser> list) {
    list.sort((a, b) => b.score.compareTo(a.score));
    final rankedList = <LeaderboardUser>[];
    for (int i = 0; i < list.length; i++) {
      final user = list[i];
      rankedList.add(
        LeaderboardUser(
          rank: i + 1,
          name: user.name,
          avatarUrl: user.avatarUrl,
          streak: user.streak,
          score: user.score,
          isCurrentUser: user.isCurrentUser,
        ),
      );
    }
    state = state.copyWith(leaderboard: rankedList);
  }
}

final progressProvider = StateNotifierProvider<ProgressNotifier, ProgressState>(
  (ref) {
    return ProgressNotifier(ref);
  },
);

// Leaderboard fetched independently so home screen always shows fresh data.
// Watches authProvider so it re-runs after login (token is set before this fires).
final homeLeaderboardProvider = FutureProvider<List<LeaderboardUser>>((ref) async {
  ref.watch(authProvider); // re-run when auth state changes
  final api = ApiService();
  final data = await api.getLeaderboard();
  final entries = data['entries'] as List<dynamic>? ?? [];
  return entries.map((e) => LeaderboardUser.fromJson(e as Map<String, dynamic>)).toList();
});

// Live today's step count from the local pedometer (written by StepsScreen).
// Home screen reads this instead of progressState.steps so both show the same number.
final todayStepsProvider = StateProvider<int>((ref) => 0);

// Initial value loaded from SharedPreferences so home shows the right number
// before the user visits the steps page.
final todayStepsCachedProvider = FutureProvider<int>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('step_today_count') ?? 0;
});
