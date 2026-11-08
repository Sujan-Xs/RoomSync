import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/lifestyle_habits.dart';
import '../../../core/models/match.dart';
import '../../../core/models/user.dart';
import '../../../core/services/compatibility_calculator.dart';
import '../../../core/services/mock_data_service.dart';
import '../../../core/services/supabase_database_service.dart';

class MatchState {
  final User currentUser;
  final List<User> candidates;
  final List<Match> matches;
  final User? latestMutualMatch;
  final bool hasCompletedOnboarding;

  const MatchState({
    required this.currentUser,
    required this.candidates,
    required this.matches,
    this.latestMutualMatch,
    this.hasCompletedOnboarding = true,
  });

  MatchState copyWith({
    User? currentUser,
    List<User>? candidates,
    List<Match>? matches,
    User? latestMutualMatch,
    bool clearMutualMatch = false,
    bool? hasCompletedOnboarding,
  }) {
    return MatchState(
      currentUser: currentUser ?? this.currentUser,
      candidates: candidates ?? this.candidates,
      matches: matches ?? this.matches,
      latestMutualMatch: clearMutualMatch ? null : (latestMutualMatch ?? this.latestMutualMatch),
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

class MatchNotifier extends StateNotifier<MatchState> {
  final SupabaseDatabaseService? _dbService;

  MatchNotifier([this._dbService])
      : super(MatchState(
          currentUser: MockDataService.currentUser,
          candidates: List.from(MockDataService.mockProfiles),
          matches: MockDataService.getMockMatches().where((m) => m.isMutual).toList(),
          hasCompletedOnboarding: true,
        )) {
    _loadLiveCandidates();
  }

  Future<void> _loadLiveCandidates() async {
    if (_dbService == null) return;
    try {
      final liveCandidates = await _dbService!.fetchCandidateProfiles(state.currentUser.id);
      final liveMatches = await _dbService!.fetchUserMatches(state.currentUser.id);

      final sorted = List<User>.from(liveCandidates)
        ..sort((a, b) {
          final scoreA = CompatibilityCalculator.calculate(state.currentUser, a).overallScore;
          final scoreB = CompatibilityCalculator.calculate(state.currentUser, b).overallScore;
          return scoreB.compareTo(scoreA);
        });

      state = state.copyWith(
        candidates: sorted,
        matches: liveMatches.where((m) => m.isMutual).toList(),
      );
    } catch (_) {}
  }

  void updateProfile({
    String? name,
    int? age,
    String? occupation,
    String? location,
    bool? isVerified,
    required LifestyleHabits habits,
  }) {
    final updatedUser = state.currentUser.copyWith(
      name: name ?? state.currentUser.name,
      age: age ?? state.currentUser.age,
      occupation: occupation ?? state.currentUser.occupation,
      location: location ?? state.currentUser.location,
      isVerified: isVerified ?? state.currentUser.isVerified,
      habits: habits,
    );

    // Re-evaluate candidate compatibility rankings with new user habits
    final sortedCandidates = List<User>.from(MockDataService.mockProfiles)
      ..sort((a, b) {
        final scoreA = CompatibilityCalculator.calculate(updatedUser, a).overallScore;
        final scoreB = CompatibilityCalculator.calculate(updatedUser, b).overallScore;
        return scoreB.compareTo(scoreA); // Highest compatibility first
      });

    state = state.copyWith(
      currentUser: updatedUser,
      candidates: sortedCandidates,
      hasCompletedOnboarding: true,
    );
  }

  void setVerified(bool isVerified) {
    state = state.copyWith(
      currentUser: state.currentUser.copyWith(isVerified: isVerified),
    );
  }

  void passCandidate(User candidate) {
    state = state.copyWith(
      candidates: state.candidates.where((u) => u.id != candidate.id).toList(),
    );
  }

  bool likeCandidate(User candidate) {
    final result = CompatibilityCalculator.calculate(state.currentUser, candidate);
    final isMutual = result.overallScore >= 68.0 || candidate.id == 'mock_user_01' || candidate.id == 'mock_user_05';

    // Persist swipe directly to Supabase matches table
    _dbService?.recordSwipe(
      currentUserId: state.currentUser.id,
      targetUserId: candidate.id,
      isLike: true,
      compatibilityScore: result.overallScore,
      scoreBreakdown: result.toBreakdownMap(),
    );

    final remaining = state.candidates.where((u) => u.id != candidate.id).toList();

    if (isMutual) {
      final newMatch = Match(
        id: 'match_${state.currentUser.id}_${candidate.id}',
        userId: state.currentUser.id,
        targetUserId: candidate.id,
        targetUser: candidate,
        compatibilityScore: result.overallScore,
        scoreBreakdown: result.toBreakdownMap(),
        isMutual: true,
        lastMessage: 'You matched with ${candidate.name}!',
        lastMessageAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final updatedMatches = [newMatch, ...state.matches.where((m) => m.targetUserId != candidate.id)];

      state = state.copyWith(
        candidates: remaining,
        matches: updatedMatches,
        latestMutualMatch: candidate,
      );
      return true;
    } else {
      state = state.copyWith(candidates: remaining);
      return false;
    }
  }

  void superlikeCandidate(User candidate) {
    final result = CompatibilityCalculator.calculate(state.currentUser, candidate);

    _dbService?.recordSwipe(
      currentUserId: state.currentUser.id,
      targetUserId: candidate.id,
      isLike: true,
      compatibilityScore: result.overallScore,
      scoreBreakdown: result.toBreakdownMap(),
    );

    final remaining = state.candidates.where((u) => u.id != candidate.id).toList();

    final newMatch = Match(
      id: 'match_${state.currentUser.id}_${candidate.id}',
      userId: state.currentUser.id,
      targetUserId: candidate.id,
      targetUser: candidate,
      compatibilityScore: result.overallScore,
      scoreBreakdown: result.toBreakdownMap(),
      isMutual: true,
      lastMessage: 'Superliked! You matched with ${candidate.name}.',
      lastMessageAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      candidates: remaining,
      matches: [newMatch, ...state.matches.where((m) => m.targetUserId != candidate.id)],
      latestMutualMatch: candidate,
    );
  }

  void clearMutualMatchDialog() {
    state = state.copyWith(clearMutualMatch: true);
  }

  void resetDeck() {
    state = state.copyWith(
      candidates: List.from(MockDataService.mockProfiles),
    );
  }
}

final matchProvider = StateNotifierProvider<MatchNotifier, MatchState>((ref) {
  final dbService = ref.watch(supabaseDatabaseProvider);
  return MatchNotifier(dbService);
});

