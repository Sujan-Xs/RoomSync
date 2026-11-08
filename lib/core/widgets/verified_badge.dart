import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

class VerifiedBadge extends StatelessWidget {
  final double size;
  final bool showLabel;
  final Color? color;

  const VerifiedBadge({
    super.key,
    this.size = 18.0,
    this.showLabel = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.verified;

    final badgeIcon = Container(
      padding: EdgeInsets.all(size * 0.15),
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        LucideIcons.check,
        size: size * 0.7,
        color: Colors.white,
      ),
    );

    if (!showLabel) {
      return badgeIcon;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          badgeIcon,
          const SizedBox(width: 6),
          Text(
            'Verified Profile',
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.w700,
              fontSize: size * 0.75,
            ),
          ),
        ],
      ),
    );
  }
}

