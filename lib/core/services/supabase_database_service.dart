import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/match.dart' as rm;
import '../models/message.dart';
import '../models/user.dart' as rm_user;
import 'mock_data_service.dart';

class SupabaseDatabaseService {
  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<rm_user.User>> fetchCandidateProfiles(String currentUserId) async {
    final client = _client;
    if (client == null) return MockDataService.mockProfiles;

    try {
      final response = await client
          .from('profiles')
          .select()
          .neq('user_id', currentUserId);

      final list = (response as List<dynamic>).map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        map['id'] = map['user_id'] ?? map['id'];
        return rm_user.User.fromJson(map);
      }).toList();

      return list.isNotEmpty ? list : MockDataService.mockProfiles;
    } catch (_) {
      return MockDataService.mockProfiles;
    }
  }

  Future<List<rm.Match>> fetchUserMatches(String currentUserId) async {
    final client = _client;
    if (client == null) return MockDataService.getMockMatches();

    try {
      final response = await client
          .from('matches')
          .select()
          .or('user_1_id.eq.$currentUserId,user_2_id.eq.$currentUserId');

      return (response as List<dynamic>).map((row) {
        return rm.Match(
          id: row['id'] as String,
          userId: row['user_1_id'] as String,
          targetUserId: row['user_2_id'] as String,
          compatibilityScore: (row['compatibility_score'] as num?)?.toDouble() ?? 80.0,
          isMutual: row['is_mutual'] as bool? ?? false,
          lastMessage: row['last_message'] as String?,
          createdAt: DateTime.parse(row['created_at'] as String),
        );
      }).toList();
    } catch (_) {
      return MockDataService.getMockMatches();
    }
  }

  Future<bool> recordSwipe({
    required String currentUserId,
    required String targetUserId,
    required bool isLike,
    required double compatibilityScore,
    Map<String, double>? scoreBreakdown,
  }) async {
    final client = _client;
    if (client == null || !isLike) return false;

    try {
      final existingInverse = await client
          .from('matches')
          .select()
          .eq('user_1_id', targetUserId)
          .eq('user_2_id', currentUserId)
          .maybeSingle();

      final isMutual = existingInverse != null;

      if (isMutual) {
        await client
            .from('matches')
            .update({'is_mutual': true})
            .eq('id', existingInverse['id']);
        return true;
      } else {
        await client.from('matches').upsert({
          'user_1_id': currentUserId,
          'user_2_id': targetUserId,
          'is_mutual': false,
          'compatibility_score': compatibilityScore,
          'score_breakdown': scoreBreakdown ?? {},
        });
        return false;
      }
    } catch (_) {
      return compatibilityScore >= 68.0;
    }
  }

  Future<void> sendChatMessage(Message message) async {
    final client = _client;
    if (client == null) return;

    try {
      await client.from('messages').insert({
        'match_id': message.matchId,
        'sender_id': message.senderId,
        'receiver_id': message.receiverId,
        'content': message.content,
        'is_read': message.isRead,
        'message_type': message.messageType.name,
        'meetup_details': message.meetupDetails?.toJson(),
      });

      await client.from('matches').update({
        'last_message': message.content,
        'last_message_at': message.timestamp.toIso8601String(),
      }).eq('id', message.matchId);
    } catch (_) {}
  }
}

final supabaseDatabaseProvider = Provider<SupabaseDatabaseService>((ref) {
  return SupabaseDatabaseService();
});

