enum SleepScheduleType { earlyBird, nightOwl, flexible }

enum SmokingPreference { nonSmoker, outsideOnly, smoker }

enum PetPreference {
  noPets,
  hasDog,
  hasCat,
  hasOther,
  petFriendly,
  allergic,
}

class LifestyleHabits {
  final int cleanlinessRating; // 1 (Relaxed) to 5 (Extremely Neat)
  final String bedtime; // e.g. "23:00" or "11 PM"
  final String wakeTime; // e.g. "07:00" or "7 AM"
  final SleepScheduleType sleepSchedule;
  final SmokingPreference smoking;
  final PetPreference petPreference;
  final double budgetMin;
  final double budgetMax;
  final String dietaryPreference;
  final String workSchedule; // e.g. "WFH", "Hybrid", "In-Office"
  final String drinkingHabit; // e.g. "Never", "Socially", "Regularly"

  const LifestyleHabits({
    required this.cleanlinessRating,
    required this.bedtime,
    required this.wakeTime,
    required this.sleepSchedule,
    required this.smoking,
    required this.petPreference,
    required this.budgetMin,
    required this.budgetMax,
    this.dietaryPreference = 'Any',
    this.workSchedule = 'Hybrid',
    this.drinkingHabit = 'Socially',
  }) : assert(cleanlinessRating >= 1 && cleanlinessRating <= 5, 'Cleanliness rating must be between 1 and 5');

  LifestyleHabits copyWith({
    int? cleanlinessRating,
    String? bedtime,
    String? wakeTime,
    SleepScheduleType? sleepSchedule,
    SmokingPreference? smoking,
    PetPreference? petPreference,
    double? budgetMin,
    double? budgetMax,
    String? dietaryPreference,
    String? workSchedule,
    String? drinkingHabit,
  }) {
    return LifestyleHabits(
      cleanlinessRating: cleanlinessRating ?? this.cleanlinessRating,
      bedtime: bedtime ?? this.bedtime,
      wakeTime: wakeTime ?? this.wakeTime,
      sleepSchedule: sleepSchedule ?? this.sleepSchedule,
      smoking: smoking ?? this.smoking,
      petPreference: petPreference ?? this.petPreference,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      workSchedule: workSchedule ?? this.workSchedule,
      drinkingHabit: drinkingHabit ?? this.drinkingHabit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cleanlinessRating': cleanlinessRating,
      'bedtime': bedtime,
      'wakeTime': wakeTime,
      'sleepSchedule': sleepSchedule.name,
      'smoking': smoking.name,
      'petPreference': petPreference.name,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'dietaryPreference': dietaryPreference,
      'workSchedule': workSchedule,
      'drinkingHabit': drinkingHabit,
    };
  }

  factory LifestyleHabits.fromJson(Map<String, dynamic> json) {
    return LifestyleHabits(
      cleanlinessRating: ((json['cleanlinessRating'] as num?)?.toInt() ?? 3).clamp(1, 5),
      bedtime: json['bedtime'] as String? ?? '23:00',
      wakeTime: json['wakeTime'] as String? ?? '07:00',
      sleepSchedule: SleepScheduleType.values.firstWhere(
        (e) => e.name == json['sleepSchedule'],
        orElse: () => SleepScheduleType.flexible,
      ),
      smoking: SmokingPreference.values.firstWhere(
        (e) => e.name == json['smoking'],
        orElse: () => SmokingPreference.nonSmoker,
      ),
      petPreference: PetPreference.values.firstWhere(
        (e) => e.name == json['petPreference'],
        orElse: () => PetPreference.petFriendly,
      ),
      budgetMin: (json['budgetMin'] as num?)?.toDouble() ?? 500.0,
      budgetMax: (json['budgetMax'] as num?)?.toDouble() ?? 1500.0,
      dietaryPreference: json['dietaryPreference'] as String? ?? 'Any',
      workSchedule: json['workSchedule'] as String? ?? 'Hybrid',
      drinkingHabit: json['drinkingHabit'] as String? ?? 'Socially',
    );
  }
}
