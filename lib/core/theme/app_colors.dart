import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Secondary
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFEEF2FF);
  
  static const Color secondary = Color(0xFF0EA5E9); // Sky
  static const Color accent = Color(0xFFEC4899); // Rose Pink (Matches/Likes)

  // Status & Compatibility Scoring
  static const Color scoreHigh = Color(0xFF10B981); // Emerald Green (>= 80%)
  static const Color scoreMedium = Color(0xFFF59E0B); // Amber (60% - 79%)
  static const Color scoreLow = Color(0xFFEF4444); // Red (< 60%)
  static const Color verified = Color(0xFF0284C7); // Twitter/Meta-style Verified Blue

  // Neutrals & Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Action Buttons
  static const Color passButton = Color(0xFFEF4444);
  static const Color superlikeButton = Color(0xFF3B82F6);
  static const Color likeButton = Color(0xFF10B981);
  static const Color coffeeSafety = Color(0xFFD97706); // Warm Amber/Coffee
}

