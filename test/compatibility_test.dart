import 'package:flutter_test/flutter_test.dart';
import 'package:roomsync/core/models/lifestyle_habits.dart';
import 'package:roomsync/core/models/user.dart';
import 'package:roomsync/core/services/compatibility_calculator.dart';

void main() {
  group('CompatibilityCalculator Tests', () {
    test('Perfect Match returns high compatibility score (>= 90%)', () {
      const habitsA = LifestyleHabits(
        cleanlinessRating: 4,
        bedtime: '11:00 PM',
        wakeTime: '07:00 AM',
        sleepSchedule: SleepScheduleType.flexible,
        smoking: SmokingPreference.nonSmoker,
        petPreference: PetPreference.petFriendly,
        budgetMin: 1200.0,
        budgetMax: 1600.0,
      );

      const habitsB = LifestyleHabits(
        cleanlinessRating: 4,
        bedtime: '11:00 PM',
        wakeTime: '07:00 AM',
        sleepSchedule: SleepScheduleType.flexible,
        smoking: SmokingPreference.nonSmoker,
        petPreference: PetPreference.petFriendly,
        budgetMin: 1200.0,
        budgetMax: 1600.0,
      );

      final result = CompatibilityCalculator.calculateDetails(
        habitsA: habitsA,
        habitsB: habitsB,
        locationA: 'Brooklyn, NY',
        locationB: 'Brooklyn, NY',
        prefLocationsA: ['Williamsburg'],
        prefLocationsB: ['Williamsburg'],
      );

      expect(result.overallScore, greaterThanOrEqualTo(90.0));
      expect(result.isDealbreaker, isFalse);
      expect(result.cleanlinessScore, equals(25.0)); // 25 out of 25
      expect(result.smokingAndPetScore, equals(20.0)); // 20 out of 20
    });

    test('Dealbreaker: Severe Pet Allergy with Pet Owner caps score <= 25%', () {
      const allergicHabits = LifestyleHabits(
        cleanlinessRating: 4,
        bedtime: '11:00 PM',
        wakeTime: '07:00 AM',
        sleepSchedule: SleepScheduleType.flexible,
        smoking: SmokingPreference.nonSmoker,
        petPreference: PetPreference.allergic,
        budgetMin: 1200.0,
        budgetMax: 1600.0,
      );

      const petOwnerHabits = LifestyleHabits(
        cleanlinessRating: 4,
        bedtime: '11:00 PM',
        wakeTime: '07:00 AM',
        sleepSchedule: SleepScheduleType.flexible,
        smoking: SmokingPreference.nonSmoker,
        petPreference: PetPreference.hasDog,
        budgetMin: 1200.0,
        budgetMax: 1600.0,
      );

      final result = CompatibilityCalculator.calculateDetails(
        habitsA: allergicHabits,
        habitsB: petOwnerHabits,
        locationA: 'Brooklyn',
        locationB: 'Brooklyn',
      );

      expect(result.isDealbreaker, isTrue);
      expect(result.overallScore, lessThanOrEqualTo(25.0));
      expect(result.dealbreakerReasons.first, contains('Pet dealbreaker'));
    });

    test('Dealbreaker: Non-Smoker with Indoor Smoker triggers dealbreaker', () {
      const nonSmoker = LifestyleHabits(
        cleanlinessRating: 3,
        bedtime: '11:00 PM',
        wakeTime: '07:00 AM',
        sleepSchedule: SleepScheduleType.flexible,
        smoking: SmokingPreference.nonSmoker,
        petPreference: PetPreference.noPets,
        budgetMin: 1000.0,
        budgetMax: 1500.0,
      );

      const smoker = LifestyleHabits(
        cleanlinessRating: 3,
        bedtime: '11:00 PM',
        wakeTime: '07:00 AM',
        sleepSchedule: SleepScheduleType.flexible,
        smoking: SmokingPreference.smoker,
        petPreference: PetPreference.noPets,
        budgetMin: 1000.0,
        budgetMax: 1500.0,
      );

      final result = CompatibilityCalculator.calculateDetails(
        habitsA: nonSmoker,
        habitsB: smoker,
        locationA: 'Queens',
        locationB: 'Queens',
      );

      expect(result.isDealbreaker, isTrue);
      expect(result.overallScore, lessThanOrEqualTo(25.0));
      expect(result.dealbreakerReasons.first, contains('Incompatible smoking habits'));
    });

    test('Sleep Schedule: Divergent sleep windows (10 PM - 6 AM vs 2 AM - 10 AM) reduce sleep score', () {
      const earlyBird = LifestyleHabits(
        cleanlinessRating: 4,
        bedtime: '10:00 PM',
        wakeTime: '06:00 AM',
        sleepSchedule: SleepScheduleType.earlyBird,
        smoking: SmokingPreference.nonSmoker,
        petPreference: PetPreference.noPets,
        budgetMin: 1200.0,
        budgetMax: 1600.0,
      );

      const nightOwl = LifestyleHabits(
        cleanlinessRating: 4,
        bedtime: '02:00 AM',
        wakeTime: '10:00 AM',
        sleepSchedule: SleepScheduleType.nightOwl,
        smoking: SmokingPreference.nonSmoker,
        petPreference: PetPreference.noPets,
        budgetMin: 1200.0,
        budgetMax: 1600.0,
      );

      final result = CompatibilityCalculator.calculateDetails(
        habitsA: earlyBird,
        habitsB: nightOwl,
      );

      expect(result.sleepScheduleScore, lessThan(10.0)); // Less than 10 out of 25 max
    });

    test('Cleanliness Rating: Extreme difference (5 vs 1) yields 0 cleanliness score', () {
      const neatFreak = LifestyleHabits(
        cleanlinessRating: 5,
        bedtime: '11:00 PM',
        wakeTime: '07:00 AM',
        sleepSchedule: SleepScheduleType.flexible,
        smoking: SmokingPreference.nonSmoker,
        petPreference: PetPreference.noPets,
        budgetMin: 1000.0,
        budgetMax: 1500.0,
      );

      const relaxed = LifestyleHabits(
        cleanlinessRating: 1,
        bedtime: '11:00 PM',
        wakeTime: '07:00 AM',
        sleepSchedule: SleepScheduleType.flexible,
        smoking: SmokingPreference.nonSmoker,
        petPreference: PetPreference.noPets,
        budgetMin: 1000.0,
        budgetMax: 1500.0,
      );

      final result = CompatibilityCalculator.calculateDetails(
        habitsA: neatFreak,
        habitsB: relaxed,
      );

      expect(result.cleanlinessScore, equals(0.0));
    });

    test('Time parsing: Correctly parses AM/PM and 24h formats across midnight', () {
      expect(CompatibilityCalculator.parseTimeToHour('11:00 PM'), equals(23.0));
      expect(CompatibilityCalculator.parseTimeToHour('1:00 AM'), equals(1.0));
      expect(CompatibilityCalculator.parseTimeToHour('12:00 AM'), equals(0.0));
      expect(CompatibilityCalculator.parseTimeToHour('12:00 PM'), equals(12.0));
      expect(CompatibilityCalculator.parseTimeToHour('06:30'), closeTo(6.5, 0.01));
    });

    test('Overall Score is strictly bounded between 0.0 and 100.0', () {
      final userA = User(
        id: 'u1',
        name: 'User 1',
        age: 22,
        gender: 'F',
        occupation: 'Designer',
        bio: '',
        avatarUrl: '',
        imageUrls: [],
        isVerified: true,
        location: 'NYC',
        preferredLocations: ['Brooklyn'],
        habits: const LifestyleHabits(
          cleanlinessRating: 1,
          bedtime: '03:00 AM',
          wakeTime: '11:00 AM',
          sleepSchedule: SleepScheduleType.nightOwl,
          smoking: SmokingPreference.smoker,
          petPreference: PetPreference.hasDog,
          budgetMin: 500.0,
          budgetMax: 700.0,
        ),
        createdAt: DateTime.now(),
      );

      final userB = User(
        id: 'u2',
        name: 'User 2',
        age: 30,
        gender: 'M',
        occupation: 'Finance',
        bio: '',
        avatarUrl: '',
        imageUrls: [],
        isVerified: true,
        location: 'LA',
        preferredLocations: ['Santa Monica'],
        habits: const LifestyleHabits(
          cleanlinessRating: 5,
          bedtime: '09:00 PM',
          wakeTime: '05:00 AM',
          sleepSchedule: SleepScheduleType.earlyBird,
          smoking: SmokingPreference.nonSmoker,
          petPreference: PetPreference.allergic,
          budgetMin: 3000.0,
          budgetMax: 5000.0,
        ),
        createdAt: DateTime.now(),
      );

      final result = CompatibilityCalculator.calculate(userA, userB);
      expect(result.overallScore, greaterThanOrEqualTo(0.0));
      expect(result.overallScore, lessThanOrEqualTo(100.0));
      expect(result.isDealbreaker, isTrue); // Pet allergy + dog & Smoker + nonSmoker
    });
  });
}

