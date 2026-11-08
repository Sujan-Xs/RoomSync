import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HabitComparisonChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isMatch;
  final bool? isAligned;

  const HabitComparisonChip({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.isMatch = true,
    this.isAligned,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMatch = isAligned ?? isMatch;

    if (value == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: effectiveMatch ? AppColors.surface : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: effectiveMatch ? AppColors.border : AppColors.scoreLow.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: effectiveMatch ? AppColors.primary : AppColors.scoreLow,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: effectiveMatch ? AppColors.surface : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: effectiveMatch ? AppColors.border : AppColors.scoreLow.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: effectiveMatch ? AppColors.primary : AppColors.scoreLow,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

