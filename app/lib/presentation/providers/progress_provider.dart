import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressState {
  final int steps;
  final double calories;
  final int mindfulMins;
  final int currentStreak;
  final int completedSessionsToday;
  final int totalSessionsToday;
  final List<int> completedDays; // e.g. [1, 2, 4] for Day 1, Day 2, Day 4 of course

  ProgressState({
    this.steps = 1250,
    this.calories = 50.0,
    this.mindfulMins = 25,
    this.currentStreak = 3,
    this.completedSessionsToday = 2,
    this.totalSessionsToday = 14,
    this.completedDays = const [1, 2, 4],
  });

  ProgressState copyWith({
    int? steps,
    double? calories,
    int? mindfulMins,
    int? currentStreak,
    int? completedSessionsToday,
    int? totalSessionsToday,
    List<int>? completedDays,
  }) {
    return ProgressState(
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      mindfulMins: mindfulMins ?? this.mindfulMins,
      currentStreak: currentStreak ?? this.currentStreak,
      completedSessionsToday: completedSessionsToday ?? this.completedSessionsToday,
      totalSessionsToday: totalSessionsToday ?? this.totalSessionsToday,
      completedDays: completedDays ?? this.completedDays,
    );
  }
}

class ProgressNotifier extends StateNotifier<ProgressState> {
  ProgressNotifier() : super(ProgressState());

  void addSteps(int increment) {
    final newSteps = state.steps + increment;
    final newCalories = newSteps * 0.04;
    state = state.copyWith(steps: newSteps, calories: newCalories);
  }

  void addMindfulMinutes(int minutes) {
    state = state.copyWith(mindfulMins: state.mindfulMins + minutes);
  }

  void completeSession() {
    final nextSessionCount = state.completedSessionsToday + 1;
    state = state.copyWith(
      completedSessionsToday: nextSessionCount > state.totalSessionsToday 
          ? state.totalSessionsToday 
          : nextSessionCount,
    );
  }

  void markDayComplete(int dayNumber) {
    if (!state.completedDays.contains(dayNumber)) {
      final updatedDays = List<int>.from(state.completedDays)..add(dayNumber);
      updatedDays.sort();
      state = state.copyWith(
        completedDays: updatedDays,
        currentStreak: state.currentStreak + 1,
      );
    }
  }

  void resetToday() {
    state = state.copyWith(
      completedSessionsToday: 0,
      steps: 0,
      calories: 0.0,
    );
  }
}

final progressProvider = StateNotifierProvider<ProgressNotifier, ProgressState>((ref) {
  return ProgressNotifier();
});
