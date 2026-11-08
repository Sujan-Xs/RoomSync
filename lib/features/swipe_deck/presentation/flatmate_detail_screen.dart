import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/lifestyle_habits.dart';
import '../../../core/models/user.dart';
import '../../../core/services/compatibility_calculator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/compatibility_badge.dart';
import '../../../core/widgets/habit_comparison_chip.dart';
import '../../../core/widgets/verified_badge.dart';

class FlatmateDetailScreen extends StatelessWidget {
  final User candidate;
  final User currentUser;
  final VoidCallback onPass;
  final VoidCallback onLike;

  const FlatmateDetailScreen({
    super.key,
    required this.candidate,
    required this.currentUser,
    required this.onPass,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final compatResult = CompatibilityCalculator.calculate(currentUser, candidate);
    final score = compatResult.overallScore;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Collapsible Image Header
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    candidate.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.primaryLight),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.6, 1.0],
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${candidate.name}, ${candidate.age}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (candidate.isVerified) ...[
                              const SizedBox(width: 8),
                              const VerifiedBadge(size: 20),
                            ],
                          ],
                        ),
                        CompatibilityBadge(
                          score: score,
                          result: compatResult,
                          isCompact: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Detail Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verification Shield Card
                  if (candidate.isVerified)
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.verified.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.verified.withOpacity(0.25)),
                      ),
                      child: const Row(
                        children: [
                          VerifiedBadge(size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Identity & Employment Verified',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.verified,
                                  ),
                                ),
                                Text(
                                  'Government ID and LinkedIn professional credentials verified.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Basic Location & Occupation
                  Row(
                    children: [
                      const Icon(LucideIcons.briefcase, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        candidate.occupation,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 16),
                      const Icon(LucideIcons.mapPin, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        candidate.location,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Bio Section
                  const Text('About Me', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    candidate.bio,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Compatibility Highlights
                  if (compatResult.positiveHighlights.isNotEmpty) ...[
                    const Text('Why You Match Well', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: compatResult.positiveHighlights.map((highlight) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.scoreHigh.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.scoreHigh.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.check, size: 14, color: AppColors.scoreHigh),
                              const SizedBox(width: 6),
                              Text(
                                highlight,
                                style: const TextStyle(
                                  color: AppColors.scoreHigh,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Lifestyle Comparison
                  const Text('Lifestyle & Habits', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      HabitComparisonChip(
                        icon: LucideIcons.wallet,
                        label: 'Budget',
                        value: '\$${candidate.habits.budgetMin.toInt()} - \$${candidate.habits.budgetMax.toInt()}',
                      ),
                      HabitComparisonChip(
                        icon: LucideIcons.moon,
                        label: 'Sleep Schedule',
                        value: '${candidate.habits.bedtime} - ${candidate.habits.wakeTime}',
                      ),
                      HabitComparisonChip(
                        icon: LucideIcons.sparkles,
                        label: 'Cleanliness',
                        value: '${candidate.habits.cleanlinessRating}/5 Rating',
                      ),
                      HabitComparisonChip(
                        icon: candidate.habits.smoking == SmokingPreference.nonSmoker
                            ? LucideIcons.cigaretteOff
                            : LucideIcons.cigarette,
                        label: 'Smoking',
                        value: candidate.habits.smoking.name,
                      ),
                      HabitComparisonChip(
                        icon: LucideIcons.dog,
                        label: 'Pets',
                        value: candidate.habits.petPreference.name,
                      ),
                      HabitComparisonChip(
                        icon: LucideIcons.laptop,
                        label: 'Work Style',
                        value: candidate.habits.workSchedule,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Preferred Neighborhoods
                  if (candidate.preferredLocations.isNotEmpty) ...[
                    const Text('Target Neighborhoods', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: candidate.preferredLocations.map((loc) {
                        return Chip(
                          backgroundColor: AppColors.surfaceMuted,
                          label: Text(loc, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          avatar: const Icon(LucideIcons.mapPin, size: 14, color: AppColors.primary),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onPass();
                },
                icon: const Icon(LucideIcons.x, color: AppColors.passButton),
                label: const Text('Pass', style: TextStyle(color: AppColors.passButton, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.passButton, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onLike();
                },
                icon: const Icon(LucideIcons.heart, color: Colors.white),
                label: const Text('Connect', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.likeButton,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

