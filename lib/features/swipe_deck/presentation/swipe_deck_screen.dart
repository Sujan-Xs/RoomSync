import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/lifestyle_habits.dart';
import '../../../core/models/user.dart';
import '../../../core/services/compatibility_calculator.dart';
import '../../../core/theme/app_colors.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../matching/controllers/match_controller.dart';
import '../../matching/presentation/match_dialog.dart';
import '../../apartments/presentation/apartments_screen.dart';
import 'discovery_filter_dialog.dart';
import 'profile_swiper.dart';

class SwipeDeckScreen extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToMatches;

  const SwipeDeckScreen({
    super.key,
    required this.onNavigateToMatches,
  });

  @override
  ConsumerState<SwipeDeckScreen> createState() => _SwipeDeckScreenState();
}

class _SwipeDeckScreenState extends ConsumerState<SwipeDeckScreen> {
  int _selectedView = 0; // 0: Flatmates, 1: Apartments
  FilterCriteria _currentFilter = FilterCriteria();

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DiscoveryFilterDialog(
        initialCriteria: _currentFilter,
        onApply: (newCriteria) {
          setState(() {
            _currentFilter = newCriteria;
          });
        },
      ),
    );
  }

  List<User> _applyFilters(List<User> candidates, User currentUser) {
    return candidates.where((candidate) {
      // Budget check
      final budgetAligns = candidate.habits.budgetMax >= _currentFilter.budgetRange.start &&
          candidate.habits.budgetMin <= _currentFilter.budgetRange.end;
      if (!budgetAligns) return false;

      // Cleanliness check
      if (candidate.habits.cleanlinessRating < _currentFilter.minCleanliness) {
        return false;
      }

      // Non-smoker only filter
      if (_currentFilter.strictNonSmokerOnly &&
          candidate.habits.smoking != SmokingPreference.nonSmoker) {
        return false;
      }

      // Pet friendly only filter
      if (_currentFilter.petFriendlyOnly &&
          candidate.habits.petPreference == PetPreference.noPets) {
        return false;
      }

      // Compatibility score threshold check
      final score = CompatibilityCalculator.calculate(currentUser, candidate).overallScore;
      if (score < _currentFilter.minCompatibilityScore) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchProvider);
    final allCandidates = matchState.candidates;
    final currentUser = matchState.currentUser;
    final filteredCandidates = _applyFilters(allCandidates, currentUser);

    // Listen for mutual matches and trigger celebratory MatchDialog overlay
    ref.listen<MatchState>(matchProvider, (previous, next) {
      if (next.latestMutualMatch != null &&
          (previous?.latestMutualMatch?.id != next.latestMutualMatch?.id)) {
        final target = next.latestMutualMatch!;
        final score = CompatibilityCalculator.calculate(currentUser, target).overallScore;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => MatchDialog(
            currentUser: currentUser,
            matchedUser: target,
            score: score,
            onKeepSwiping: () {
              Navigator.of(ctx).pop();
              ref.read(matchProvider.notifier).clearMutualMatchDialog();
            },
            onStartChat: () {
              Navigator.of(ctx).pop();
              ref.read(matchProvider.notifier).clearMutualMatchDialog();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    matchId: 'match_${currentUser.id}_${target.id}',
                    targetUser: target,
                  ),
                ),
              );
            },
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.home, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'RoomSync',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          if (_selectedView == 0) ...[
            // Filter Button
            IconButton(
              icon: const Icon(LucideIcons.slidersHorizontal, color: AppColors.textSecondary),
              tooltip: 'Filter Flatmates',
              onPressed: _showFilterDialog,
            ),
            // Reset Deck Button
            IconButton(
              icon: const Icon(LucideIcons.rotateCcw, color: AppColors.textSecondary),
              tooltip: 'Reset Deck',
              onPressed: () {
                ref.read(matchProvider.notifier).resetDeck();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile deck reset!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Segmented Switch: Flatmates vs Apartments
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.surface,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedView = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedView == 0 ? AppColors.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedView == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.users,
                                size: 16,
                                color: _selectedView == 0 ? AppColors.primary : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Flatmates',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedView == 0 ? AppColors.primary : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedView = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedView == 1 ? AppColors.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedView == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.home,
                                size: 16,
                                color: _selectedView == 1 ? AppColors.primary : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Apartments',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedView == 1 ? AppColors.primary : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // Main Content Area
            Expanded(
              child: _selectedView == 1
                  ? const ApartmentsScreen()
                  : (filteredCandidates.isEmpty
                      ? _buildEmptyDeckState()
                      : ProfileSwiper(
                          candidates: filteredCandidates,
                          currentUser: currentUser,
                          onDeckEmpty: () {
                            setState(() {});
                          },
                        )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDeckState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.compass, size: 56, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Profiles Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No flatmate profiles match your current filter settings. Try resetting filters or resetting the deck.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentFilter = FilterCriteria();
                    });
                  },
                  icon: const Icon(LucideIcons.filterX, size: 16),
                  label: const Text('Clear Filters'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(matchProvider.notifier).resetDeck();
                  },
                  icon: const Icon(LucideIcons.rotateCcw, size: 16),
                  label: const Text('Reset Deck'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
