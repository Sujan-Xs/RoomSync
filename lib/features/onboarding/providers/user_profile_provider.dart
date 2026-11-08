import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/lifestyle_habits.dart';
import '../../../core/models/user.dart';
import '../../../core/services/mock_data_service.dart';
import '../../matching/controllers/match_controller.dart';

class UserProfileNotifier extends StateNotifier<User> {
  static const String _storageKey = 'roomsync_persisted_profile';
  final Ref _ref;

  UserProfileNotifier(this._ref) : super(MockDataService.currentUser) {
    loadPersistedProfile();
  }

  Future<void> loadPersistedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        final loadedUser = User.fromJson(map);
        state = loadedUser;
        // Sync with matchProvider
        _ref.read(matchProvider.notifier).updateProfile(
              name: loadedUser.name,
              age: loadedUser.age,
              occupation: loadedUser.occupation,
              location: loadedUser.location,
              isVerified: loadedUser.isVerified,
              habits: loadedUser.habits,
            );
      }
    } catch (_) {}
  }

  Future<void> saveProfile({
    required String name,
    required int age,
    required String gender,
    required String occupation,
    required String bio,
    required String avatarUrl,
    required String location,
    required List<String> preferredLocations,
    required LifestyleHabits habits,
  }) async {
    final updatedUser = state.copyWith(
      name: name,
      age: age,
      gender: gender,
      occupation: occupation,
      bio: bio,
      avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : state.avatarUrl,
      location: location,
      preferredLocations: preferredLocations,
      habits: habits,
    );

    state = updatedUser;

    // 1. Persist to SharedPreferences and live Supabase Cloud
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(updatedUser.toJson()));

      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId != null) {
        await client.from('profiles').upsert({
          'user_id': userId,
          'name': updatedUser.name,
          'age': updatedUser.age,
          'gender': updatedUser.gender,
          'occupation': updatedUser.occupation,
          'bio': updatedUser.bio,
          'avatar_url': updatedUser.avatarUrl,
          'location': updatedUser.location,
          'preferred_locations': updatedUser.preferredLocations,
          'budget': updatedUser.habits.budgetMax,
          'sleep_start': updatedUser.habits.bedtime,
          'sleep_end': updatedUser.habits.wakeTime,
          'cleanliness_score': updatedUser.habits.cleanlinessRating,
          'smoking': updatedUser.habits.smoking.name,
          'pets': updatedUser.habits.petPreference.name,
          'is_verified': updatedUser.isVerified,
          'habits': updatedUser.habits.toJson(),
        });
      }
    } catch (_) {}

    // 2. Immediately re-calculate compatibility match percentages across all swipe deck cards
    _ref.read(matchProvider.notifier).updateProfile(
          name: updatedUser.name,
          age: updatedUser.age,
          occupation: updatedUser.occupation,
          location: updatedUser.location,
          isVerified: updatedUser.isVerified,
          habits: updatedUser.habits,
        );
  }

  Future<void> setVerified(bool isVerified) async {
    final updatedUser = state.copyWith(isVerified: isVerified);
    state = updatedUser;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(updatedUser.toJson()));
    } catch (_) {}
    _ref.read(matchProvider.notifier).setVerified(isVerified);
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, User>((ref) {
  return UserProfileNotifier(ref);
});

