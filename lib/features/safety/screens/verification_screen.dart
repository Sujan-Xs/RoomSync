import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../matching/controllers/match_controller.dart';
import '../../onboarding/providers/user_profile_provider.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  bool _isIdUploaded = true;
  bool _isSelfieVerified = true;
  late bool _isVerifiedToggle;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _isVerifiedToggle = ref.read(matchProvider).currentUser.isVerified;
  }

  void _applyVerification() {
    setState(() => _isSubmitting = true);

    ref.read(userProfileProvider.notifier).setVerified(_isVerifiedToggle);
    ref.read(matchProvider.notifier).setVerified(_isVerifiedToggle);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isVerifiedToggle
                ? 'Identity Verified! Blue Verified Flatmate badge activated.'
                : 'Verified badge status updated.'),
            backgroundColor: AppColors.scoreHigh,
          ),
        );
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Identity Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.verified.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.badgeCheck, color: AppColors.verified, size: 48),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Verified Flatmate Program',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Verified badges build trust and result in 3x more mutual roommate matches.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 28),

            // Step 1: Government Photo ID
            _buildStepCard(
              icon: LucideIcons.idCard,
              title: 'Step 1: Government Photo ID',
              desc: 'Passport, Driver\'s License, or State ID card.',
              isDone: _isIdUploaded,
              onTap: () => setState(() => _isIdUploaded = !_isIdUploaded),
            ),
            const SizedBox(height: 14),

            // Step 2: Live Selfie Check
            _buildStepCard(
              icon: LucideIcons.camera,
              title: 'Step 2: Real-time Selfie Check',
              desc: 'Face-match verification against your submitted photo ID.',
              isDone: _isSelfieVerified,
              onTap: () => setState(() => _isSelfieVerified = !_isSelfieVerified),
            ),
            const SizedBox(height: 20),

            // Verified Status Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Display "Verified Flatmate" Badge', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Shows verified checkmark on Discover card deck and in chats.', style: TextStyle(fontSize: 12)),
                value: _isVerifiedToggle,
                activeColor: AppColors.verified,
                onChanged: (val) => setState(() => _isVerifiedToggle = val),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _applyVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.verified,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _isSubmitting ? 'Verifying...' : 'Save Verification Status',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDone,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? AppColors.verified.withOpacity(0.4) : AppColors.border,
          width: isDone ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDone ? AppColors.verified.withOpacity(0.12) : AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isDone ? AppColors.verified : AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isDone ? LucideIcons.checkCircle2 : LucideIcons.circle,
              color: isDone ? AppColors.verified : AppColors.textTertiary,
              size: 22,
            ),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

