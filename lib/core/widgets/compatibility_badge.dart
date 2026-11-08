import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/compatibility_calculator.dart';
import '../theme/app_colors.dart';

class CompatibilityBadge extends StatelessWidget {
  final double score;
  final CompatibilityResult? result;
  final bool isCompact;
  final double? size;

  const CompatibilityBadge({
    super.key,
    required this.score,
    this.result,
    this.isCompact = false,
    this.size,
  });

  Color _getScoreColor(double score) {
    if (score >= 80.0) return AppColors.scoreHigh;
    if (score >= 60.0) return AppColors.scoreMedium;
    return AppColors.scoreLow;
  }

  void _showBreakdownModal(BuildContext context) {
    if (result == null) return;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getScoreColor(score).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.sparkles,
                        color: _getScoreColor(score),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Compatibility Breakdown',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getScoreColor(score),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${score.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildMetricBar(
              context,
              'Budget & Location',
              result!.budgetAndLocationScore,
              30.0,
              LucideIcons.wallet,
            ),
            _buildMetricBar(
              context,
              'Sleep Schedule',
              result!.sleepScheduleScore,
              25.0,
              LucideIcons.moon,
            ),
            _buildMetricBar(
              context,
              'Cleanliness Standards',
              result!.cleanlinessScore,
              25.0,
              LucideIcons.sparkles,
            ),
            _buildMetricBar(
              context,
              'Smoking & Pets',
              result!.smokingAndPetScore,
              20.0,
              LucideIcons.dog,
            ),
            if (result!.dealbreakerReasons.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.scoreLow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.scoreLow.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertTriangle, color: AppColors.scoreLow, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result!.dealbreakerReasons.join(', '),
                        style: const TextStyle(
                          color: AppColors.scoreLow,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBar(
    BuildContext context,
    String title,
    double current,
    double maxVal,
    IconData icon,
  ) {
    final progress = (current / maxVal).clamp(0.0, 1.0);
    final color = _getScoreColor(progress * 100);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '${current.toStringAsFixed(1)} / ${maxVal.toInt()} pts',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor(score);

    if (size != null) {
      return GestureDetector(
        onTap: () => _showBreakdownModal(context),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${score.toInt()}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: (size! * 0.32).clamp(10.0, 15.0),
                ),
              ),
              if (size! >= 44)
                Text(
                  'MATCH',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 7.5,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (isCompact) {
      return GestureDetector(
        onTap: () => _showBreakdownModal(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.5), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.sparkles, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                '${score.toInt()}% Match',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showBreakdownModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.65),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.sparkles,
                size: 13,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${score.toInt()}% Match',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              LucideIcons.chevronRight,
              size: 14,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}

