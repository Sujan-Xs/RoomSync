import '../models/lifestyle_habits.dart';
import '../models/match.dart';
import '../models/message.dart';
import '../models/user.dart';
import 'compatibility_calculator.dart';

class MockDataService {
  /// The active profile (Alex Morgan)
  static final User currentUser = User(
    id: 'user_current_001',
    name: 'Alex Morgan',
    age: 25,
    gender: 'Non-binary',
    occupation: 'Product Designer',
    bio: 'Passionate about typography, house plants, and Sunday farmers markets. Looking for a mindful, tidy flatmate in Brooklyn.',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
    imageUrls: [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
    ],
    isVerified: true,
    location: 'Brooklyn, NY',
    preferredLocations: ['Williamsburg', 'Greenpoint', 'Bushwick'],
    habits: const LifestyleHabits(
      cleanlinessRating: 4,
      bedtime: '11:00 PM',
      wakeTime: '07:00 AM',
      sleepSchedule: SleepScheduleType.flexible,
      smoking: SmokingPreference.nonSmoker,
      petPreference: PetPreference.petFriendly,
      budgetMin: 1100.0,
      budgetMax: 1650.0,
      dietaryPreference: 'Vegetarian',
      workSchedule: 'Hybrid (3 days WFH)',
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  /// 10 diverse flatmate profiles with varying sleep schedules, cleanliness, budgets, and dealbreakers
  static final List<User> mockProfiles = [
    // 1. Elena - High compatibility (similar budget, sleep, habits)
    User(
      id: 'mock_user_01',
      name: 'Elena Rostova',
      age: 24,
      gender: 'Female',
      occupation: 'UX/UI Designer',
      bio: 'Loves pour-over coffee, curated Spotify playlists, and quiet weeknights. Very respectful of shared spaces and cleanliness.',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80',
      ],
      isVerified: true,
      location: 'Brooklyn, NY',
      preferredLocations: ['Williamsburg', 'Greenpoint', 'Bushwick'],
      habits: const LifestyleHabits(
        cleanlinessRating: 4,
        bedtime: '11:00 PM',
        wakeTime: '07:00 AM',
        sleepSchedule: SleepScheduleType.flexible,
        smoking: SmokingPreference.nonSmoker,
        petPreference: PetPreference.hasCat,
        budgetMin: 1200.0,
        budgetMax: 1600.0,
        dietaryPreference: 'Any',
        workSchedule: 'Hybrid',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),

    // 2. Marcus - High budget, neat freak, allergy dealbreaker
    User(
      id: 'mock_user_02',
      name: 'Marcus Chen',
      age: 27,
      gender: 'Male',
      occupation: 'Senior Staff Engineer',
      bio: 'Minimalist techie. Gym early morning, quiet evenings. Clean counters are an absolute essential for me.',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80',
      ],
      isVerified: true,
      location: 'Manhattan, NY',
      preferredLocations: ['East Village', 'Chelsea', 'SoHo'],
      habits: const LifestyleHabits(
        cleanlinessRating: 5,
        bedtime: '12:00 AM',
        wakeTime: '08:00 AM',
        sleepSchedule: SleepScheduleType.flexible,
        smoking: SmokingPreference.nonSmoker,
        petPreference: PetPreference.allergic,
        budgetMin: 2000.0,
        budgetMax: 2800.0,
        dietaryPreference: 'Pescatarian',
        workSchedule: 'In-Office',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),

    // 3. Maya - Night owl, modest budget, student
    User(
      id: 'mock_user_03',
      name: 'Maya Patel',
      age: 23,
      gender: 'Female',
      occupation: 'Architecture Student',
      bio: 'Currently finishing my thesis. Expect late-night studio sessions and lots of drafting boards. Friendly cat named Chai!',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
      ],
      isVerified: false,
      location: 'Queens, NY',
      preferredLocations: ['Astoria', 'Long Island City', 'Sunnyside'],
      habits: const LifestyleHabits(
        cleanlinessRating: 3,
        bedtime: '01:30 AM',
        wakeTime: '09:00 AM',
        sleepSchedule: SleepScheduleType.nightOwl,
        smoking: SmokingPreference.outsideOnly,
        petPreference: PetPreference.hasCat,
        budgetMin: 850.0,
        budgetMax: 1250.0,
        dietaryPreference: 'Vegetarian',
        workSchedule: 'Student / Freelance',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),

    // 4. Liam - Early bird, dog owner, photographer
    User(
      id: 'mock_user_04',
      name: 'Liam O\'Connor',
      age: 29,
      gender: 'Male',
      occupation: 'Architectural Photographer',
      bio: 'Up at sunrise for golden hour shoots. Golden retriever named Barnaby who loves everyone. Super relaxed roommate.',
      avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80',
      ],
      isVerified: true,
      location: 'Brooklyn, NY',
      preferredLocations: ['Greenpoint', 'Williamsburg'],
      habits: const LifestyleHabits(
        cleanlinessRating: 3,
        bedtime: '10:00 PM',
        wakeTime: '06:00 AM',
        sleepSchedule: SleepScheduleType.earlyBird,
        smoking: SmokingPreference.nonSmoker,
        petPreference: PetPreference.hasDog,
        budgetMin: 1400.0,
        budgetMax: 1900.0,
        dietaryPreference: 'Any',
        workSchedule: 'Flexible',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),

    // 5. Sofia - Balanced professional, tidy, social
    User(
      id: 'mock_user_05',
      name: 'Sofia Rodriguez',
      age: 26,
      gender: 'Female',
      occupation: 'Growth Marketing Manager',
      bio: 'Balancing startup life with running along Brooklyn Bridge Park. Love cooking tapas on weekends and wine nights.',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
      ],
      isVerified: true,
      location: 'Brooklyn, NY',
      preferredLocations: ['Brooklyn Heights', 'Cobble Hill', 'Williamsburg'],
      habits: const LifestyleHabits(
        cleanlinessRating: 4,
        bedtime: '11:30 PM',
        wakeTime: '07:30 AM',
        sleepSchedule: SleepScheduleType.flexible,
        smoking: SmokingPreference.outsideOnly,
        petPreference: PetPreference.petFriendly,
        budgetMin: 1400.0,
        budgetMax: 1850.0,
        dietaryPreference: 'Any',
        workSchedule: 'Hybrid',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),

    // 6. Kai - Smoker, late night DJ, low cleanliness (Dealbreaker test)
    User(
      id: 'mock_user_06',
      name: 'Kai Takahashi',
      age: 25,
      gender: 'Male',
      occupation: 'Music Producer & DJ',
      bio: 'Night shift life. Studio gear everywhere. Social, passionate about underground vinyl and synth jams.',
      avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=800&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=800&q=80',
      ],
      isVerified: false,
      location: 'Brooklyn, NY',
      preferredLocations: ['Bushwick', 'Bed-Stuy', 'Ridgewood'],
      habits: const LifestyleHabits(
        cleanlinessRating: 2,
        bedtime: '02:30 AM',
        wakeTime: '10:30 AM',
        sleepSchedule: SleepScheduleType.nightOwl,
        smoking: SmokingPreference.smoker,
        petPreference: PetPreference.petFriendly,
        budgetMin: 850.0,
        budgetMax: 1250.0,
        dietaryPreference: 'Any',
        workSchedule: 'Night Shifts',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
    ),

    // 7. Chloe - Extreme early bird baker, 5/5 cleanliness
    User(
      id: 'mock_user_07',
      name: 'Chloe Dubois',
      age: 28,
      gender: 'Female',
      occupation: 'Artisan Pastry Chef',
      bio: 'Up at 4:30 AM to bake sourdough. Free croissants for the flat! Spotless kitchen hygiene is second nature to me.',
      avatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80',
      ],
      isVerified: true,
      location: 'Manhattan, NY',
      preferredLocations: ['Lower East Side', 'Greenpoint', 'Williamsburg'],
      habits: const LifestyleHabits(
        cleanlinessRating: 5,
        bedtime: '09:30 PM',
        wakeTime: '05:00 AM',
        sleepSchedule: SleepScheduleType.earlyBird,
        smoking: SmokingPreference.nonSmoker,
        petPreference: PetPreference.noPets,
        budgetMin: 1250.0,
        budgetMax: 1700.0,
        dietaryPreference: 'Vegetarian',
        workSchedule: 'Early Morning Shifts',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),

    // 8. Devon - Corporate high budget, no pets, disciplined
    User(
      id: 'mock_user_08',
      name: 'Devon Washington',
      age: 30,
      gender: 'Male',
      occupation: 'Private Equity Associate',
      bio: 'Structured schedule, frequent business travel. Looking for a quiet, high-end 2BR in FiDi or Tribeca.',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80',
      ],
      isVerified: true,
      location: 'Manhattan, NY',
      preferredLocations: ['Financial District', 'Battery Park', 'Tribeca'],
      habits: const LifestyleHabits(
        cleanlinessRating: 4,
        bedtime: '10:30 PM',
        wakeTime: '06:30 AM',
        sleepSchedule: SleepScheduleType.earlyBird,
        smoking: SmokingPreference.nonSmoker,
        petPreference: PetPreference.noPets,
        budgetMin: 2200.0,
        budgetMax: 3200.0,
        dietaryPreference: 'Any',
        workSchedule: 'In-Office (Long hours)',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 22)),
    ),

    // 9. Aria - Great budget match, dog lover, plant mom
    User(
      id: 'mock_user_09',
      name: 'Aria Sharma',
      age: 22,
      gender: 'Female',
      occupation: 'Environmental Policy Fellow',
      bio: 'Passionate about composting, weekend farmers markets, and my Australian Shepherd pup Mochi. Great roomie vibes.',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=800&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=800&q=80',
      ],
      isVerified: true,
      location: 'Brooklyn, NY',
      preferredLocations: ['Park Slope', 'Prospect Heights', 'Crown Heights'],
      habits: const LifestyleHabits(
        cleanlinessRating: 4,
        bedtime: '11:00 PM',
        wakeTime: '07:00 AM',
        sleepSchedule: SleepScheduleType.flexible,
        smoking: SmokingPreference.nonSmoker,
        petPreference: PetPreference.hasDog,
        budgetMin: 1100.0,
        budgetMax: 1550.0,
        dietaryPreference: 'Vegan',
        workSchedule: 'Remote / WFH',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),

    // 10. Zack - Illustrator, moderate budget, night owl
    User(
      id: 'mock_user_10',
      name: 'Zack Miller',
      age: 26,
      gender: 'Male',
      occupation: 'Freelance Concept Artist',
      bio: 'Drawing characters on Cintiq, drinking matcha, looking for chill people who respect creative space.',
      avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=800&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=800&q=80',
      ],
      isVerified: false,
      location: 'Queens, NY',
      preferredLocations: ['Ridgewood', 'Bushwick'],
      habits: const LifestyleHabits(
        cleanlinessRating: 2,
        bedtime: '01:00 AM',
        wakeTime: '08:30 AM',
        sleepSchedule: SleepScheduleType.nightOwl,
        smoking: SmokingPreference.outsideOnly,
        petPreference: PetPreference.petFriendly,
        budgetMin: 950.0,
        budgetMax: 1350.0,
        dietaryPreference: 'Vegetarian',
        workSchedule: 'Freelance / WFH',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  /// Generate mock matches with precomputed compatibility breakdown
  static List<Match> getMockMatches() {
    return mockProfiles.map((target) {
      final result = CompatibilityCalculator.calculate(currentUser, target);
      final isMutual = result.overallScore >= 70.0;

      return Match(
        id: 'match_${currentUser.id}_${target.id}',
        userId: currentUser.id,
        targetUserId: target.id,
        targetUser: target,
        compatibilityScore: result.overallScore,
        scoreBreakdown: result.toBreakdownMap(),
        isMutual: isMutual,
        lastMessage: isMutual ? 'Hey Alex! Saw your profile and loved your apartment vision.' : null,
        lastMessageAt: isMutual ? DateTime.now().subtract(const Duration(hours: 3)) : null,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      );
    }).toList();
  }

  /// Initial mock message thread for Elena Rostova with "Schedule Coffee Meetup" example
  static List<Message> getMockMessagesForElena(String matchId) {
    return [
      Message(
        id: 'msg_01',
        matchId: matchId,
        senderId: 'mock_user_01',
        receiverId: currentUser.id,
        content: 'Hi Alex! It’s awesome to connect. I saw you’re also searching around Greenpoint & Williamsburg!',
        timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
        isRead: true,
      ),
      Message(
        id: 'msg_02',
        matchId: matchId,
        senderId: currentUser.id,
        receiverId: 'mock_user_01',
        content: 'Hey Elena! Yes! Our budget ranges and cleanliness preferences line up really well too.',
        timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 10)),
        isRead: true,
      ),
      Message(
        id: 'msg_03',
        matchId: matchId,
        senderId: 'mock_user_01',
        receiverId: currentUser.id,
        content: 'Totally! Would you be up for a quick public meetup to see if we’d be a good roommate fit?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
        isRead: true,
      ),
      Message(
        id: 'msg_04',
        matchId: matchId,
        senderId: 'mock_user_01',
        receiverId: currentUser.id,
        content: 'I sent over a coffee meetup invite at Devocion in Williamsburg!',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 14)),
        isRead: true,
        messageType: MessageType.coffeeMeetupInvite,
        meetupDetails: CoffeeMeetupDetails(
          venueName: 'Devoción Coffee Roasters',
          address: '69 Grand St, Brooklyn, NY 11249',
          scheduledTime: DateTime.now().add(const Duration(days: 2, hours: 3)),
          status: MeetupStatus.pending,
        ),
      ),
    ];
  }
}

