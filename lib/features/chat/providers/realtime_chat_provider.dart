import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/message.dart';
import '../../../core/services/mock_data_service.dart';

final realtimeChatStreamProvider = StreamProvider.family<List<Message>, String>((ref, matchId) {
  if (AppConstants.useMockData) {
    return Stream.value(MockDataService.getMockMessagesForElena(matchId));
  }

  try {
    final client = Supabase.instance.client;

    return client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('match_id', matchId)
        .order('created_at', ascending: true)
        .map((rows) {
          return rows.map((row) {
            final map = Map<String, dynamic>.from(row);
            map['timestamp'] = map['created_at'];
            return Message.fromJson(map);
          }).toList();
        }).handleError((_) {
          return MockDataService.getMockMessagesForElena(matchId);
        });
  } catch (_) {
    return Stream.value(MockDataService.getMockMessagesForElena(matchId));
  }
});

