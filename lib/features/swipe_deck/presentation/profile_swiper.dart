import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/lifestyle_habits.dart';
import '../../../core/models/user.dart';
import '../../../core/services/compatibility_calculator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/compatibility_badge.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../matching/controllers/match_controller.dart';
import 'flatmate_detail_screen.dart';

class ProfileSwiper extends ConsumerStatefulWidget {
  final List<User> candidates;
  final User currentUser;
  final VoidCallback onDeckEmpty;

  const ProfileSwiper({
    super.key,
    required this.candidates,
    required this.currentUser,
    required this.onDeckEmpty,
  });

  @override
  ConsumerState<ProfileSwiper> createState() => _ProfileSwiperState();
}

class _ProfileSwiperState extends ConsumerState<ProfileSwiper> {
  late final CardSwiperController _swiperController;

  @override
  void initState() {
    super.initState();
    _swiperController = CardSwiperController();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  bool _handleSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (previousIndex >= widget.candidates.length) return true;
    final candidate = widget.candidates[previousIndex];

    if (direction == CardSwiperDirection.right) {
      ref.read(matchProvider.notifier).likeCandidate(candidate);
    } else if (direction == CardSwiperDirection.left) {
      ref.read(matchProvider.notifier).passCandidate(candidate);
    } else if (direction == CardSwiperDirection.top) {
      ref.read(matchProvider.notifier).superlikeCandidate(candidate);
    }

    if (currentIndex == null || currentIndex >= widget.candidates.length) {
      widget.onDeckEmpty();
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.candidates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Fluid Card Stack
        Expanded(
          child: CardSwiper(
            controller: _swiperController,
            cardsCount: widget.candidates.length,
            numberOfCardsDisplayed: widget.candidates.length > 2 ? 3 : widget.candidates.length,
            backCardOffset: const Offset(0, 32),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            cardBuilder: (context, index, percentX, percentY) {
              final candidate = widget.candidates[index];
              return _buildCard(candidate);
            },
            onSwipe: _handleSwipe,
          ),
        ),

        // Bottom Action Controls (Undo, Dislike/Pass, Superlike, Like)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Undo / Rewind button
              _buildActionButton(
                icon: LucideIcons.undo2,
                color: AppColors.scoreMedium,
                size: 46,
                onPressed: () => _swiperController.undo(),
              ),
              // Dislike / Pass (Red Cross)
              _buildActionButton(
                icon: LucideIcons.x,
                color: AppColors.passButton,
                size: 58,
                onPressed: () => _swiperController.swipe(CardSwiperDirection.left),
              ),
              // Superlike (Blue Star)
              _buildActionButton(
                icon: LucideIcons.star,
                color: AppColors.superlikeButton,
                size: 48,
                onPressed: () => _swiperController.swipe(CardSwiperDirection.top),
              ),
              // Like (Green Heart)
              _buildActionButton(
                icon: LucideIcons.heart,
                color: AppColors.likeButton,
                size: 58,
                onPressed: () => _swiperController.swipe(CardSwiperDirection.right),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(User candidate) {
    final compatResult = CompatibilityCalculator.calculate(widget.currentUser, candidate);
    final score = compatResult.overallScore;
    final tags = _generateHabitTags(candidate);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FlatmateDetailScreen(
              candidate: candidate,
              currentUser: widget.currentUser,
              onPass: () => _swiperController.swipe(CardSwiperDirection.left),
              onLike: () => _swiperController.swipe(CardSwiperDirection.right),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Profile Photo Placeholder / Image
              Image.network(
                candidate.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.primaryLight,
                  child: const Center(
                    child: Icon(LucideIcons.user, size: 72, color: AppColors.primary),
                  ),
                ),
              ),

              // Gradient Shading for Text Legibility
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.45, 0.72, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.65),
                        Colors.black.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ),

              // Top Header: Large Compatibility Badge & Verified Shield
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CompatibilityBadge(
                      score: score,
                      result: compatResult,
                    ),
                    if (candidate.isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.verified, width: 1.2),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            VerifiedBadge(size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Bottom Profile Info & Habit Comparison Tags
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name, Age & Verified Checkmark
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${candidate.name}, ${candidate.age}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        if (candidate.isVerified) ...[
                          const SizedBox(width: 8),
                          const VerifiedBadge(size: 20),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Location & Budget Details
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            candidate.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Icon(LucideIcons.wallet, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          '\$${candidate.habits.budgetMin.toInt()} - \$${candidate.habits.budgetMax.toInt()}/mo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Habit Comparison Tags (Early Riser, Clean Freak, Pet Friendly, etc.)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags.map((t) => _buildHabitTagChip(t)).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<({IconData icon, String label, Color color})> _generateHabitTags(User candidate) {
    final tags = <({IconData icon, String label, Color color})>[];

    // Cleanliness tag
    if (candidate.habits.cleanlinessRating >= 5) {
      tags.add((icon: LucideIcons.sparkles, label: 'Clean Freak', color: AppColors.scoreHigh));
    } else if (candidate.habits.cleanlinessRating == 4) {
      tags.add((icon: LucideIcons.sparkles, label: 'Tidy & Neat', color: AppColors.scoreHigh));
    } else {
      tags.add((icon: LucideIcons.coffee, label: 'Relaxed Living', color: AppColors.scoreMedium));
    }

    // Sleep schedule tag
    if (candidate.habits.sleepSchedule == SleepScheduleType.earlyBird) {
      tags.add((icon: LucideIcons.sunrise, label: 'Early Riser', color: AppColors.secondary));
    } else if (candidate.habits.sleepSchedule == SleepScheduleType.nightOwl) {
      tags.add((icon: LucideIcons.moon, label: 'Night Owl', color: AppColors.primary));
    } else {
      tags.add((icon: LucideIcons.clock, label: 'Flexible Rhythms', color: AppColors.secondary));
    }

    // Pet tag
    if (candidate.habits.petPreference == PetPreference.hasDog) {
      tags.add((icon: LucideIcons.dog, label: 'Dog Parent', color: AppColors.scoreMedium));
    } else if (candidate.habits.petPreference == PetPreference.hasCat) {
      tags.add((icon: LucideIcons.cat, label: 'Cat Parent', color: AppColors.scoreMedium));
    } else if (candidate.habits.petPreference == PetPreference.petFriendly) {
      tags.add((icon: LucideIcons.heart, label: 'Pet Friendly', color: AppColors.scoreHigh));
    } else if (candidate.habits.petPreference == PetPreference.allergic) {
      tags.add((icon: LucideIcons.alertTriangle, label: 'Pet Allergic', color: AppColors.scoreLow));
    }

    // Smoking tag
    if (candidate.habits.smoking == SmokingPreference.nonSmoker) {
      tags.add((icon: LucideIcons.cigaretteOff, label: 'Smoke-Free', color: AppColors.scoreHigh));
    } else if (candidate.habits.smoking == SmokingPreference.outsideOnly) {
      tags.add((icon: LucideIcons.wind, label: 'Outdoor Smoker', color: AppColors.scoreMedium));
    }

    return tags;
  }

  Widget _buildHabitTagChip(({IconData icon, String label, Color color}) tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tag.color.withOpacity(0.55), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tag.icon, size: 13, color: tag.color),
          const SizedBox(width: 6),
          Text(
            tag.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: color, size: size * 0.45),
        ),
      ),
    );
  }
}

