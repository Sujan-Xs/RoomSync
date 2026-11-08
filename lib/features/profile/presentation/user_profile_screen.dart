import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/habit_comparison_chip.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../matching/controllers/match_controller.dart';
import '../../onboarding/screens/edit_profile_screen.dart';
import '../../onboarding/screens/profile_setup_screen.dart';
import '../../safety/screens/verification_screen.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchState = ref.watch(matchProvider);
    final user = matchState.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Roommate Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit3, color: AppColors.primary),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.shieldAlert, color: AppColors.coffeeSafety),
            tooltip: 'Safety Tips',
            onPressed: () => _showSafetyGuidelinesModal(context),
          ),
          IconButton(
            icon: const Icon(LucideIcons.logOut, color: AppColors.textTertiary),
            tooltip: 'Sign Out',
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signed out of RoomSync.')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Card Header
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2.5),
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundImage: NetworkImage(user.avatarUrl),
                    ),
                  ),
                  if (user.isVerified)
                    const Positioned(
                      bottom: 4,
                      right: 4,
                      child: VerifiedBadge(size: 26),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Name & Age
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${user.name}, ${user.age}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (user.isVerified) ...[
                  const SizedBox(width: 6),
                  const VerifiedBadge(size: 16),
                ],
              ],
            ),
            const SizedBox(height: 4),

            // Occupation & Location
            Text(
              '${user.occupation} • ${user.location}',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Edit Profile & Wizard Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                  icon: const Icon(LucideIcons.pencil, size: 15),
                  label: const Text('Edit Habits'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfileSetupScreen(
                          onComplete: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile setup completed & saved!'),
                                backgroundColor: AppColors.scoreHigh,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.sparkles, size: 15, color: AppColors.accent),
                  label: const Text('Setup Wizard'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Identity Verification Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: user.isVerified
                    ? AppColors.verified.withOpacity(0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: user.isVerified
                      ? AppColors.verified.withOpacity(0.35)
                      : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            user.isVerified ? LucideIcons.badgeCheck : LucideIcons.shield,
                            color: user.isVerified ? AppColors.verified : AppColors.textSecondary,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.isVerified ? 'Identity Verified' : 'Verify Your Identity',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: user.isVerified ? AppColors.verified : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                user.isVerified
                                    ? 'Government ID & Employment verified'
                                    : 'Boost match rates by up to 3x',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (!user.isVerified)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const VerificationScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Verify', style: TextStyle(fontSize: 12)),
                        )
                      else
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const VerificationScreen()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            side: const BorderSide(color: AppColors.verified),
                          ),
                          child: const Text('Manage', style: TextStyle(fontSize: 12, color: AppColors.verified)),
                        ),
                    ],
                  ),
                  if (user.isVerified) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _VerificationCheckItem(icon: LucideIcons.idCard, label: 'Govt. ID'),
                        _VerificationCheckItem(icon: LucideIcons.mail, label: 'Work Email'),
                        _VerificationCheckItem(icon: LucideIcons.phone, label: 'Phone No.'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bio Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('About Me', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(
                    user.bio,
                    style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Lifestyle Habits Overview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Living Habits',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      HabitComparisonChip(
                        icon: LucideIcons.wallet,
                        label: 'Budget',
                        value: '\$${user.habits.budgetMin.toInt()} - \$${user.habits.budgetMax.toInt()}',
                      ),
                      HabitComparisonChip(
                        icon: LucideIcons.moon,
                        label: 'Sleep',
                        value: '${user.habits.bedtime} - ${user.habits.wakeTime}',
                      ),
                      HabitComparisonChip(
                        icon: LucideIcons.sparkles,
                        label: 'Cleanliness',
                        value: '${user.habits.cleanlinessRating}/5 Rating',
                      ),
                      HabitComparisonChip(
                        icon: LucideIcons.cigaretteOff,
                        label: 'Smoking',
                        value: user.habits.smoking.name,
                      ),
                      HabitComparisonChip(
                        icon: LucideIcons.glassWater,
                        label: 'Drinking',
                        value: user.habits.drinkingHabit,
                      ),
                      HabitComparisonChip(
                        icon: LucideIcons.dog,
                        label: 'Pets',
                        value: user.habits.petPreference.name,
                      ),
                      HabitComparisonChip(
                        icon: LucideIcons.laptop,
                        label: 'Work Style',
                        value: user.habits.workSchedule,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSafetyGuidelinesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.coffeeSafety.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.shieldCheck, color: AppColors.coffeeSafety, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Roommate Safety Guidelines',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _SafetyTipItem(
              icon: LucideIcons.coffee,
              title: 'Schedule a Coffee Meetup First',
              desc: 'Always meet in daylight at a busy, public cafe before visiting any apartment.',
            ),
            const _SafetyTipItem(
              icon: LucideIcons.badgeCheck,
              title: 'Look for Verified Badges',
              desc: 'Flatmates with verified badges have verified photo ID and employment records.',
            ),
            const _SafetyTipItem(
              icon: LucideIcons.banknote,
              title: 'Never Wire Deposits In Advance',
              desc: 'Do not transfer cash, crypto, or rent deposits before touring and signing a lease.',
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _VerificationCheckItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _VerificationCheckItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.verified),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.verified,
          ),
        ),
      ],
    );
  }
}

class _SafetyTipItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _SafetyTipItem({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
