import 'dart:math';
import '../models/lifestyle_habits.dart';
import '../models/user.dart';

class CompatibilityResult {
  final double overallScore; // 0.0 to 100.0
  final double budgetAndLocationScore; // 0.0 to 30.0
  final double sleepScheduleScore; // 0.0 to 25.0
  final double cleanlinessScore; // 0.0 to 25.0
  final double smokingAndPetScore; // 0.0 to 20.0
  final bool isDealbreaker;
  final List<String> dealbreakerReasons;
  final List<String> positiveHighlights;

  const CompatibilityResult({
    required this.overallScore,
    required this.budgetAndLocationScore,
    required this.sleepScheduleScore,
    required this.cleanlinessScore,
    required this.smokingAndPetScore,
    this.isDealbreaker = false,
    this.dealbreakerReasons = const [],
    this.positiveHighlights = const [],
  });

  Map<String, double> toBreakdownMap() {
    return {
      'Budget & Location': budgetAndLocationScore,
      'Sleep Schedule': sleepScheduleScore,
      'Cleanliness': cleanlinessScore,
      'Smoking & Pets': smokingAndPetScore,
    };
  }
}

class CompatibilityCalculator {
  // Configured Weights (Total: 100%)
  static const double weightBudgetAndLocation = 30.0;
  static const double weightSleep = 25.0;
  static const double weightCleanliness = 25.0;
  static const double weightSmokingAndPets = 20.0;

  /// Calculate full compatibility between two User instances.
  static CompatibilityResult calculate(User userA, User userB) {
    return calculateDetails(
      habitsA: userA.habits,
      habitsB: userB.habits,
      locationA: userA.location,
      locationB: userB.location,
      prefLocationsA: userA.preferredLocations,
      prefLocationsB: userB.preferredLocations,
    );
  }

  /// Low-level detailed compatibility calculation.
  static CompatibilityResult calculateDetails({
    required LifestyleHabits habitsA,
    required LifestyleHabits habitsB,
    String locationA = '',
    String locationB = '',
    List<String> prefLocationsA = const [],
    List<String> prefLocationsB = const [],
  }) {
    final dealbreakerReasons = <String>[];
    final positiveHighlights = <String>[];

    // 1. Budget (18%) & Location (12%) -> Max 30 points
    final budgetRatio = _evaluateBudgetOverlap(habitsA, habitsB);
    final locationRatio = _evaluateLocation(
      locationA,
      locationB,
      prefLocationsA,
      prefLocationsB,
    );
    final budgetAndLocationScore =
        ((budgetRatio * 0.18) + (locationRatio * 0.12)) / 0.30 * weightBudgetAndLocation;

    if (budgetRatio >= 0.8) {
      positiveHighlights.add('Budgets align well');
    }
    if (locationRatio >= 0.8) {
      positiveHighlights.add('Shared preferred neighborhoods');
    }

    // 2. Sleep Schedule Window (25%) -> Max 25 points
    final sleepRatio = _evaluateSleepSchedule(habitsA, habitsB);
    final sleepScheduleScore = sleepRatio * weightSleep;

    if (sleepRatio >= 0.85) {
      positiveHighlights.add('Synchronized sleep rhythms');
    }

    // 3. Cleanliness Variance (25%) -> Max 25 points
    final cleanlinessRatio = _evaluateCleanliness(habitsA.cleanlinessRating, habitsB.cleanlinessRating);
    final cleanlinessScore = cleanlinessRatio * weightCleanliness;

    if (cleanlinessRatio >= 0.8) {
      positiveHighlights.add('Matching cleanliness standards');
    }

    // 4. Smoking & Pet dealbreaker toggles (20%) -> Max 20 points
    final smokingResult = _evaluateSmoking(habitsA.smoking, habitsB.smoking);
    final petResult = _evaluatePets(habitsA.petPreference, habitsB.petPreference);

    if (smokingResult.isDealbreaker) {
      dealbreakerReasons.add('Incompatible smoking habits: ${smokingResult.reason}');
    }
    if (petResult.isDealbreaker) {
      dealbreakerReasons.add('Pet dealbreaker: ${petResult.reason}');
    }

    final smokingAndPetScore =
        ((smokingResult.score * 0.10) + (petResult.score * 0.10)) / 0.20 * weightSmokingAndPets;

    if (smokingResult.score >= 0.9 && petResult.score >= 0.9) {
      positiveHighlights.add('Complementary home lifestyle');
    }

    // Total raw summation
    double rawTotal = budgetAndLocationScore +
        sleepScheduleScore +
        cleanlinessScore +
        smokingAndPetScore;

    final isDealbreaker = dealbreakerReasons.isNotEmpty;

    // Dealbreaker cap: If dealbreaker triggered, limit overall score to max 25%
    if (isDealbreaker) {
      rawTotal = min(rawTotal * 0.35, 25.0);
    }

    final finalScore = (rawTotal.clamp(0.0, 100.0) * 10).round() / 10.0;

    return CompatibilityResult(
      overallScore: finalScore,
      budgetAndLocationScore: (budgetAndLocationScore * 10).round() / 10.0,
      sleepScheduleScore: (sleepScheduleScore * 10).round() / 10.0,
      cleanlinessScore: (cleanlinessScore * 10).round() / 10.0,
      smokingAndPetScore: (smokingAndPetScore * 10).round() / 10.0,
      isDealbreaker: isDealbreaker,
      dealbreakerReasons: dealbreakerReasons,
      positiveHighlights: positiveHighlights,
    );
  }

  // Helper: Budget Overlap
  static double _evaluateBudgetOverlap(LifestyleHabits a, LifestyleHabits b) {
    final overlapMin = max(a.budgetMin, b.budgetMin);
    final overlapMax = min(a.budgetMax, b.budgetMax);

    if (overlapMax >= overlapMin) {
      // Overlap exists
      final overlapSpan = overlapMax - overlapMin;
      final minSpan = min(a.budgetMax - a.budgetMin, b.budgetMax - b.budgetMin);
      if (minSpan <= 0) return 1.0;
      return (overlapSpan / minSpan).clamp(0.4, 1.0);
    } else {
      // Gap exists
      final gap = overlapMin - overlapMax;
      if (gap <= 100) return 0.50;
      if (gap <= 250) return 0.25;
      if (gap <= 400) return 0.10;
      return 0.0;
    }
  }

  // Helper: Location Preference
  static double _evaluateLocation(
    String locA,
    String locB,
    List<String> prefsA,
    List<String> prefsB,
  ) {
    // Check if either list shares an exact preferred neighborhood
    final setA = prefsA.map((e) => e.trim().toLowerCase()).toSet();
    final setB = prefsB.map((e) => e.trim().toLowerCase()).toSet();

    if (setA.isNotEmpty && setB.isNotEmpty && setA.intersection(setB).isNotEmpty) {
      return 1.0;
    }

    if (locA.isNotEmpty && locB.isNotEmpty && locA.toLowerCase() == locB.toLowerCase()) {
      return 1.0;
    }

    // Cross-check location against preferences
    if (setB.contains(locA.trim().toLowerCase()) || setA.contains(locB.trim().toLowerCase())) {
      return 0.85;
    }

    // Check partial containment (e.g., both contain "Brooklyn" or "New York")
    if (locA.isNotEmpty && locB.isNotEmpty) {
      final termsA = locA.toLowerCase().split(RegExp(r'[\s,/]+'));
      for (final term in termsA) {
        if (term.length > 3 && locB.toLowerCase().contains(term)) {
          return 0.65;
        }
      }
    }

    return 0.35; // Default modest baseline for flexible flat-seekers
  }

  // Helper: Sleep Schedule Window
  static double _evaluateSleepSchedule(LifestyleHabits a, LifestyleHabits b) {
    final bedHourA = parseTimeToHour(a.bedtime);
    final bedHourB = parseTimeToHour(b.bedtime);
    final wakeHourA = parseTimeToHour(a.wakeTime);
    final wakeHourB = parseTimeToHour(b.wakeTime);

    final bedDiff = _circularHourDiff(bedHourA, bedHourB);
    final wakeDiff = _circularHourDiff(wakeHourA, wakeHourB);
    final avgDiff = (bedDiff + wakeDiff) / 2.0;

    double score;
    if (avgDiff <= 1.0) {
      score = 1.0;
    } else if (avgDiff <= 2.0) {
      score = 0.75;
    } else if (avgDiff <= 3.0) {
      score = 0.45;
    } else if (avgDiff <= 4.0) {
      score = 0.20;
    } else {
      score = 0.05;
    }

    // Bonus for matching chronotype
    if (a.sleepSchedule == b.sleepSchedule) {
      score = min(1.0, score + 0.15);
    } else if ((a.sleepSchedule == SleepScheduleType.earlyBird &&
            b.sleepSchedule == SleepScheduleType.nightOwl) ||
        (a.sleepSchedule == SleepScheduleType.nightOwl &&
            b.sleepSchedule == SleepScheduleType.earlyBird)) {
      score = max(0.0, score - 0.15);
    }

    return score;
  }

  // Helper: Cleanliness Rating Variance (1 to 5)
  static double _evaluateCleanliness(int a, int b) {
    final diff = (a - b).abs();
    switch (diff) {
      case 0:
        return 1.0;
      case 1:
        return 0.80;
      case 2:
        return 0.50;
      case 3:
        return 0.20;
      case 4:
      default:
        return 0.0;
    }
  }

  // Helper: Smoking Dealbreakers
  static ({double score, bool isDealbreaker, String? reason}) _evaluateSmoking(
    SmokingPreference a,
    SmokingPreference b,
  ) {
    if (a == b) {
      return (score: 1.0, isDealbreaker: false, reason: null);
    }

    // Strict dealbreaker: Non-smoker paired with regular smoker
    if ((a == SmokingPreference.nonSmoker && b == SmokingPreference.smoker) ||
        (a == SmokingPreference.smoker && b == SmokingPreference.nonSmoker)) {
      return (
        score: 0.0,
        isDealbreaker: true,
        reason: 'Indoor/regular smoker with non-smoker'
      );
    }

    // Non-smoker + outside only smoker
    if ((a == SmokingPreference.nonSmoker && b == SmokingPreference.outsideOnly) ||
        (a == SmokingPreference.outsideOnly && b == SmokingPreference.nonSmoker)) {
      return (score: 0.60, isDealbreaker: false, reason: null);
    }

    // Outside only + smoker
    return (score: 0.70, isDealbreaker: false, reason: null);
  }

  // Helper: Pet Dealbreakers
  static ({double score, bool isDealbreaker, String? reason}) _evaluatePets(
    PetPreference a,
    PetPreference b,
  ) {
    final aHasPet = a == PetPreference.hasDog || a == PetPreference.hasCat || a == PetPreference.hasOther;
    final bHasPet = b == PetPreference.hasDog || b == PetPreference.hasCat || b == PetPreference.hasOther;

    // Strict dealbreaker: Pet allergy paired with pet owner
    if ((a == PetPreference.allergic && bHasPet) || (b == PetPreference.allergic && aHasPet)) {
      return (
        score: 0.0,
        isDealbreaker: true,
        reason: 'Severe pet allergy conflict with pet owner'
      );
    }

    if (a == PetPreference.allergic && b == PetPreference.noPets) {
      return (score: 1.0, isDealbreaker: false, reason: null);
    }

    if (a == PetPreference.noPets && b == PetPreference.noPets) {
      return (score: 1.0, isDealbreaker: false, reason: null);
    }

    if ((aHasPet || a == PetPreference.petFriendly) && (bHasPet || b == PetPreference.petFriendly)) {
      return (score: 1.0, isDealbreaker: false, reason: null);
    }

    if (aHasPet && b == PetPreference.noPets) {
      return (score: 0.35, isDealbreaker: false, reason: null);
    }

    if (bHasPet && a == PetPreference.noPets) {
      return (score: 0.35, isDealbreaker: false, reason: null);
    }

    return (score: 0.75, isDealbreaker: false, reason: null);
  }

  /// Circular hour difference on a 24-hour clock.
  static double _circularHourDiff(double a, double b) {
    final raw = (a - b).abs();
    return min(raw, 24.0 - raw);
  }

  /// Robust parser for time formats: "23:00", "11 PM", "10:30 PM", "7 AM", etc.
  static double parseTimeToHour(String timeStr) {
    final trimmed = timeStr.trim().toUpperCase();

    // Format: "10 PM", "10:30 PM", "1 AM"
    final amPmMatch = RegExp(r'^(\d{1,2})(?::(\d{2}))?\s*(AM|PM)$').firstMatch(trimmed);
    if (amPmMatch != null) {
      int hour = int.parse(amPmMatch.group(1)!);
      final minute = amPmMatch.group(2) != null ? int.parse(amPmMatch.group(2)!) : 0;
      final isPm = amPmMatch.group(3) == 'PM';
      if (isPm && hour < 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
      return hour + (minute / 60.0);
    }

    // Format: "23:00", "07:30"
    final colonMatch = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(trimmed);
    if (colonMatch != null) {
      final hour = int.parse(colonMatch.group(1)!);
      final minute = int.parse(colonMatch.group(2)!);
      return hour + (minute / 60.0);
    }

    // Raw integer hour: "23"
    final intMatch = RegExp(r'^(\d{1,2})$').firstMatch(trimmed);
    if (intMatch != null) {
      return int.parse(intMatch.group(1)!).toDouble();
    }

    return 23.0; // Default fallback
  }
}

