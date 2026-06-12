import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../../data/models/course_model.dart';

class FreeVideosState {
  final List<FreeVideoModel> videos;
  final bool isLoading;
  final String? error;

  const FreeVideosState({
    this.videos = const [],
    this.isLoading = false,
    this.error,
  });

  FreeVideosState copyWith({
    List<FreeVideoModel>? videos,
    bool? isLoading,
    String? error,
  }) {
    return FreeVideosState(
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class FreeVideosNotifier extends StateNotifier<FreeVideosState> {
  final ApiService _apiService = ApiService();

  FreeVideosNotifier() : super(const FreeVideosState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _apiService
          .getFreeVideos()
          .timeout(const Duration(seconds: 10));
      state = state.copyWith(
        videos: data.map((e) => FreeVideoModel.fromJson(e)).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => _load();
}

final freeVideosProvider =
    StateNotifierProvider<FreeVideosNotifier, FreeVideosState>((ref) {
  return FreeVideosNotifier();
});
