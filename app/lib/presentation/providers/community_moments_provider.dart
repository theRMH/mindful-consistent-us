import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../../data/models/course_model.dart';

class CommunityMomentsState {
  final List<CommunityMomentModel> moments;
  final bool isLoading;

  const CommunityMomentsState({this.moments = const [], this.isLoading = false});

  CommunityMomentsState copyWith({List<CommunityMomentModel>? moments, bool? isLoading}) {
    return CommunityMomentsState(
      moments: moments ?? this.moments,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CommunityMomentsNotifier extends StateNotifier<CommunityMomentsState> {
  final ApiService _apiService = ApiService();

  CommunityMomentsNotifier() : super(const CommunityMomentsState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _apiService
          .getCommunityMoments()
          .timeout(const Duration(seconds: 10));
      state = state.copyWith(
        moments: data.map((e) => CommunityMomentModel.fromJson(e)).toList(),
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final communityMomentsProvider =
    StateNotifierProvider<CommunityMomentsNotifier, CommunityMomentsState>((ref) {
  return CommunityMomentsNotifier();
});
