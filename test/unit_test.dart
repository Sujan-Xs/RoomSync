import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomsync/core/models/lifestyle_habits.dart';
import 'package:roomsync/core/models/message.dart';
import 'package:roomsync/core/services/apartment_service.dart';
import 'package:roomsync/core/services/mock_data_service.dart';
import 'package:roomsync/core/services/supabase_auth_service.dart';
import 'package:roomsync/core/services/supabase_database_service.dart';
import 'package:roomsync/features/chat/controllers/chat_controller.dart';
import 'package:roomsync/features/matching/controllers/match_controller.dart';
import 'package:roomsync/features/onboarding/providers/user_profile_provider.dart';

void main() {
  group('RoomSync Unit & State Tests', () {
    test('LifestyleHabits JSON serialization retains all habit fields and drinking habit', () {
      const habits = LifestyleHabits(
        cleanlinessRating: 4,
        bedtime: '11:00 PM',
        wakeTime: '07:00 AM',
        sleepSchedule: SleepScheduleType.flexible,
        smoking: SmokingPreference.nonSmoker,
        petPreference: PetPreference.petFriendly,
        budgetMin: 1200.0,
        budgetMax: 1800.0,
        dietaryPreference: 'Vegetarian',
        workSchedule: 'Hybrid',
        drinkingHabit: 'Socially',
      );

      final json = habits.toJson();
      expect(json['cleanlinessRating'], equals(4));
      expect(json['drinkingHabit'], equals('Socially'));
      expect(json['smoking'], equals('nonSmoker'));

      final reconstructed = LifestyleHabits.fromJson(json);
      expect(reconstructed.cleanlinessRating, equals(4));
      expect(reconstructed.drinkingHabit, equals('Socially'));
      expect(reconstructed.budgetMin, equals(1200.0));
    });

    test('MatchNotifier initializes with 10 candidate profiles and currentUser', () {
      final container = ProviderContainer();
      final matchState = container.read(matchProvider);

      expect(matchState.candidates.length, equals(10));
      expect(matchState.currentUser.name, equals('Alex Morgan'));
      expect(matchState.currentUser.isVerified, isTrue);
    });

    test('MatchNotifier: Liking candidate Elena Rostova triggers mutual match', () {
      final container = ProviderContainer();
      final elena = MockDataService.mockProfiles.firstWhere((p) => p.name == 'Elena Rostova');

      final isMutual = container.read(matchProvider.notifier).likeCandidate(elena);
      final updatedState = container.read(matchProvider);

      expect(isMutual, isTrue);
      expect(updatedState.latestMutualMatch?.name, equals('Elena Rostova'));
      expect(updatedState.matches.any((m) => m.targetUserId == elena.id), isTrue);
      // Candidate should be removed from remaining deck
      expect(updatedState.candidates.any((u) => u.id == elena.id), isFalse);
    });

    test('MatchNotifier: Passing candidate removes profile from deck without creating match', () {
      final container = ProviderContainer();
      final target = MockDataService.mockProfiles[5]; // Kai Takahashi

      container.read(matchProvider.notifier).passCandidate(target);
      final updatedState = container.read(matchProvider);

      expect(updatedState.candidates.any((u) => u.id == target.id), isFalse);
      expect(updatedState.matches.any((m) => m.targetUserId == target.id), isFalse);
    });

    test('ChatNotifier: Instant message dispatch adds message to state immediately with zero delay', () {
      final container = ProviderContainer();
      const matchId = 'test_match_001';

      container.read(chatProvider.notifier).sendMessage(
            matchId: matchId,
            senderId: 'user_01',
            receiverId: 'user_02',
            content: 'Hey, are you still looking for a 2BR in Greenpoint?',
          );

      final messages = container.read(chatProvider.notifier).getMessages(matchId);
      expect(messages.length, equals(1));
      expect(messages.first.content, equals('Hey, are you still looking for a 2BR in Greenpoint?'));
      expect(messages.first.isRead, isTrue);
    });

    test('ChatNotifier: Schedule Coffee Meetup creates pending meetup invite and updates status', () {
      final container = ProviderContainer();
      const matchId = 'test_match_002';
      final meetupTime = DateTime.now().add(const Duration(days: 2));

      container.read(chatProvider.notifier).scheduleCoffeeMeetup(
            matchId: matchId,
            senderId: 'user_01',
            receiverId: 'user_02',
            venueName: 'Devoción Coffee Roasters',
            address: '69 Grand St, Brooklyn',
            scheduledTime: meetupTime,
          );

      final messages = container.read(chatProvider.notifier).getMessages(matchId);
      expect(messages.length, equals(1));
      expect(messages.first.messageType, equals(MessageType.coffeeMeetupInvite));
      expect(messages.first.meetupDetails?.venueName, equals('Devoción Coffee Roasters'));
      expect(messages.first.meetupDetails?.status, equals(MeetupStatus.pending));

      // Accept meetup
      container.read(chatProvider.notifier).updateMeetupStatus(
            matchId: matchId,
            messageId: messages.first.id,
            newStatus: MeetupStatus.accepted,
          );

      final updatedMessages = container.read(chatProvider.notifier).getMessages(matchId);
      expect(updatedMessages.first.meetupDetails?.status, equals(MeetupStatus.accepted));
    });

    test('UserProfileNotifier loads default user profile and updates preferences', () async {
      final container = ProviderContainer();
      final user = container.read(userProfileProvider);

      expect(user.name, equals('Alex Morgan'));

      await container.read(userProfileProvider.notifier).saveProfile(
            name: 'Alex M.',
            age: 26,
            gender: 'Non-binary',
            occupation: 'Lead Product Designer',
            bio: 'Updated bio testing profile persistence.',
            avatarUrl: user.avatarUrl,
            location: 'Williamsburg, NY',
            preferredLocations: ['Williamsburg', 'Greenpoint'],
            habits: user.habits.copyWith(cleanlinessRating: 5, budgetMax: 2000.0),
          );

      final updatedUser = container.read(userProfileProvider);
      expect(updatedUser.name, equals('Alex M.'));
      expect(updatedUser.age, equals(26));
      expect(updatedUser.habits.cleanlinessRating, equals(5));
      expect(updatedUser.habits.budgetMax, equals(2000.0));
    });

    test('UserProfileNotifier and MatchNotifier setVerified updates and syncs verification state', () async {
      final container = ProviderContainer();
      expect(container.read(userProfileProvider).isVerified, isTrue);

      await container.read(userProfileProvider.notifier).setVerified(false);
      expect(container.read(userProfileProvider).isVerified, isFalse);
      expect(container.read(matchProvider).currentUser.isVerified, isFalse);

      await container.read(userProfileProvider.notifier).setVerified(true);
      expect(container.read(userProfileProvider).isVerified, isTrue);
      expect(container.read(matchProvider).currentUser.isVerified, isTrue);
    });

    test('ApartmentService provides 5 verified listings with valid host flatmates', () async {
      final apartments = await ApartmentService.fetchApartments();
      expect(apartments.length, equals(5));

      final firstApt = apartments.first;
      expect(firstApt.neighborhood, equals('Williamsburg'));
      expect(firstApt.monthlyRent, equals(1450.0));
      expect(firstApt.host.name, equals('Elena Rostova'));
      expect(firstApt.amenities.contains('In-unit Washer/Dryer'), isTrue);

      final json = firstApt.toJson();
      expect(json['id'], equals('apt_01'));
      expect(json['monthlyRent'], equals(1450.0));
    });

    test('SupabaseAuthService & DatabaseService provide robust fallbacks when offline', () async {
      final container = ProviderContainer();
      final authService = container.read(authServiceProvider);
      expect(authService.isClientReady, isFalse);
      expect(authService.currentUser, isNull);

      final dbService = container.read(supabaseDatabaseProvider);
      final candidates = await dbService.fetchCandidateProfiles('any_user_id');
      expect(candidates.isNotEmpty, isTrue);

      final isMutual = await dbService.recordSwipe(
        currentUserId: 'user_a',
        targetUserId: 'user_b',
        isLike: true,
        compatibilityScore: 92.0,
      );
      expect(isMutual, isTrue);
    });
  });
}

