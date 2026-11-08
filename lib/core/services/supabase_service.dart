import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../constants/app_constants.dart';
import '../models/message.dart';
import '../models/user.dart';
import 'mock_data_service.dart';

abstract class ICloudService {
  Future<User?> getCurrentUser();
  Future<List<User>> fetchCandidateProfiles();
  Stream<List<Message>> streamMessages(String matchId);
  Future<void> sendMessage(Message message);
}

class SupabaseService implements ICloudService {
  static sb.SupabaseClient? get _client {
    if (AppConstants.useMockData) return null;
    try {
      return sb.Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Initialize Supabase client if enabled in AppConstants
  static Future<void> initialize() async {
    if (AppConstants.useMockData) return;

    await sb.Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  /// Sign In with Email & Password
  static Future<sb.AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    if (AppConstants.useMockData || _client == null) return null;
    return await _client!.auth.signInWithPassword(email: email, password: password);
  }

  /// Sign Up with Email & Password
  static Future<sb.AuthResponse?> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    if (AppConstants.useMockData || _client == null) return null;
    return await _client!.auth.signUp(email: email, password: password, data: data);
  }

  /// Sign Out
  static Future<void> signOut() async {
    if (AppConstants.useMockData || _client == null) return;
    await _client!.auth.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    if (AppConstants.useMockData || _client == null) {
      return MockDataService.currentUser;
    }

    try {
      final userId = _client!.auth.currentUser?.id;
      if (userId == null) return MockDataService.currentUser;

      final response = await _client!.from('profiles').select().eq('id', userId).single();
      return User.fromJson(response);
    } catch (_) {
      return MockDataService.currentUser;
    }
  }

  @override
  Future<List<User>> fetchCandidateProfiles() async {
    if (AppConstants.useMockData || _client == null) {
      return MockDataService.mockProfiles;
    }

    try {
      final userId = _client!.auth.currentUser?.id;
      final query = _client!.from('profiles').select();
      final response = userId != null ? await query.neq('id', userId) : await query;

      return (response as List<dynamic>).map((json) => User.fromJson(json)).toList();
    } catch (_) {
      return MockDataService.mockProfiles;
    }
  }

  @override
  Stream<List<Message>> streamMessages(String matchId) {
    if (AppConstants.useMockData || _client == null) {
      return Stream.value(MockDataService.getMockMessagesForElena(matchId));
    }

    try {
      return _client!
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('match_id', matchId)
          .order('created_at', ascending: true)
          .map((data) => data.map((json) => Message.fromJson(json)).toList());
    } catch (_) {
      return Stream.value([]);
    }
  }

  @override
  Future<void> sendMessage(Message message) async {
    if (AppConstants.useMockData || _client == null) return;

    try {
      await _client!.from('messages').insert({
        'id': message.id,
        'match_id': message.matchId,
        'sender_id': message.senderId,
        'receiver_id': message.receiverId,
        'content': message.content,
        'is_read': message.isRead,
        'message_type': message.messageType.name,
        'meetup_details': message.meetupDetails?.toJson(),
        'created_at': message.timestamp.toIso8601String(),
      });
    } catch (e) {
      // Fallback
    }
  }
}
