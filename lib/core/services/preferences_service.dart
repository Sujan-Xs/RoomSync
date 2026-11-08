import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class PreferencesService {
  static const String _keyCurrentUser = 'roomsync_current_user';
  static const String _keyOnboardingDone = 'roomsync_onboarding_completed';
  static const String _keyLikedIds = 'roomsync_liked_ids';
  static const String _keyPassedIds = 'roomsync_passed_ids';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  bool get isOnboardingCompleted => _prefs.getBool(_keyOnboardingDone) ?? false;

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(_keyOnboardingDone, value);
  }

  Future<void> saveCurrentUser(User user) async {
    final jsonStr = jsonEncode(user.toJson());
    await _prefs.setString(_keyCurrentUser, jsonStr);
  }

  User? getCurrentUser() {
    final jsonStr = _prefs.getString(_keyCurrentUser);
    if (jsonStr == null) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return User.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  List<String> getLikedUserIds() {
    return _prefs.getStringList(_keyLikedIds) ?? [];
  }

  Future<void> addLikedUserId(String id) async {
    final current = getLikedUserIds();
    if (!current.contains(id)) {
      current.add(id);
      await _prefs.setStringList(_keyLikedIds, current);
    }
  }

  List<String> getPassedUserIds() {
    return _prefs.getStringList(_keyPassedIds) ?? [];
  }

  Future<void> addPassedUserId(String id) async {
    final current = getPassedUserIds();
    if (!current.contains(id)) {
      current.add(id);
      await _prefs.setStringList(_keyPassedIds, current);
    }
  }

  Future<void> clearSwipes() async {
    await _prefs.remove(_keyLikedIds);
    await _prefs.remove(_keyPassedIds);
  }
}

