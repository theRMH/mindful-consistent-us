import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../../core/config/app_config.dart';

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
  final List<LeaderboardUser> leaderboard;
  final bool isLoading;
  final String? error;

  ProgressState({
    this.steps = 1250,
    this.calories = 50.0,
    this.mindfulMins = 25,
    this.currentStreak = 3,
    this.completedSessionsToday = 2,
    this.totalSessionsToday = 14,
    this.completedDays = const [1, 2, 4],
    this.leaderboard = const [],
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
    List<LeaderboardUser>? leaderboard,
    bool? isLoading,
    String? error,
  }) {
    return ProgressState(
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      mindfulMins: mindfulMins ?? this.mindfulMins,
      currentStreak: currentStreak ?? this.currentStreak,
      completedSessionsToday: completedSessionsToday ?? this.completedSessionsToday,
      totalSessionsToday: totalSessionsToday ?? this.totalSessionsToday,
      completedDays: completedDays ?? this.completedDays,
      leaderboard: leaderboard ?? this.leaderboard,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProgressNotifier extends StateNotifier<ProgressState> {
  final ApiService _apiService = ApiService();

  ProgressNotifier() : super(ProgressState()) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    if (AppConfig.useMockData) {
      // Load premium mocks matching Figma V2 design
      state = state.copyWith(
        steps: 1250,
        calories: 50.0,
        mindfulMins: 25,
        currentStreak: 3,
        completedSessionsToday: 2,
        totalSessionsToday: 14,
        completedDays: [1, 2, 4],
        leaderboard: [
          LeaderboardUser(rank: 1, name: 'Priya S', avatarUrl: 'assets/avatar_priya.png', streak: 12, score: 1420, isCurrentUser: false),
          LeaderboardUser(rank: 2, name: 'Rohit K', avatarUrl: 'assets/avatar_rohit.png', streak: 8, score: 980, isCurrentUser: false),
          LeaderboardUser(rank: 3, name: 'You', avatarUrl: '', streak: 3, score: 120, isCurrentUser: true),
        ],
      );
    } else {
      await refreshFromApi();
    }
  }

  Future<void> refreshFromApi() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final progressData = await _apiService.getProgress();
      final leaderboardData = await _apiService.getLeaderboard();

      final stats = progressData['stats'] ?? {};
      final compDays = List<int>.from(progressData['completedDays'] ?? []);

      final leaderboardList = (leaderboardData as List)
          .map((item) => LeaderboardUser.fromJson(item))
          .toList();

      state = state.copyWith(
        steps: stats['totalSteps'] ?? 0,
        calories: (stats['totalCalories'] as num?)?.toDouble() ?? 0.0,
        mindfulMins: stats['mindfulMins'] ?? 0,
        currentStreak: stats['currentStreak'] ?? 0,
        completedSessionsToday: stats['totalSessions'] ?? 0,
        completedDays: compDays,
        leaderboard: leaderboardList,
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
        final res = await _apiService.simulateProgress({'steps': increment});
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

  Future<void> markDayComplete(int dayNumber) async {
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
        // Assume default course is the 30-day course slug/ID
        await _apiService.completeDay('30-days-yoga', dayNumber);
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
          LeaderboardUser(rank: 1, name: 'Priya S', avatarUrl: 'assets/avatar_priya.png', streak: 12, score: 1420, isCurrentUser: false),
          LeaderboardUser(rank: 2, name: 'Rohit K', avatarUrl: 'assets/avatar_rohit.png', streak: 8, score: 980, isCurrentUser: false),
          LeaderboardUser(rank: 3, name: 'You', avatarUrl: '', streak: 0, score: 0, isCurrentUser: true),
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
    final calculatedScore = state.completedDays.length * 100 + state.currentStreak * 10;
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
      rankedList.add(LeaderboardUser(
        rank: i + 1,
        name: user.name,
        avatarUrl: user.avatarUrl,
        streak: user.streak,
        score: user.score,
        isCurrentUser: user.isCurrentUser,
      ));
    }
    state = state.copyWith(leaderboard: rankedList);
  }
}

final progressProvider = StateNotifierProvider<ProgressNotifier, ProgressState>((ref) {
  return ProgressNotifier();
});
