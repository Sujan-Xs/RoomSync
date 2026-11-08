import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/message.dart';
import '../../../core/services/mock_data_service.dart';
import '../../../core/services/supabase_database_service.dart';

class ChatState {
  final Map<String, List<Message>> messagesByMatchId;

  const ChatState({
    required this.messagesByMatchId,
  });

  ChatState copyWith({
    Map<String, List<Message>>? messagesByMatchId,
  }) {
    return ChatState(
      messagesByMatchId: messagesByMatchId ?? this.messagesByMatchId,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final SupabaseDatabaseService? _dbService;

  ChatNotifier([this._dbService])
      : super(ChatState(
          messagesByMatchId: {
            'match_user_current_001_mock_user_01':
                MockDataService.getMockMessagesForElena('match_user_current_001_mock_user_01'),
          },
        ));

  List<Message> getMessages(String matchId) {
    return state.messagesByMatchId[matchId] ?? [];
  }

  void sendMessage({
    required String matchId,
    required String senderId,
    required String receiverId,
    required String content,
  }) {
    final newMessage = Message(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      matchId: matchId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
      isRead: true,
      messageType: MessageType.text,
    );

    // Sync to Supabase messages table in real-time
    _dbService?.sendChatMessage(newMessage);

    final currentMessages = List<Message>.from(state.messagesByMatchId[matchId] ?? []);
    currentMessages.add(newMessage);

    final updatedMap = Map<String, List<Message>>.from(state.messagesByMatchId);
    updatedMap[matchId] = currentMessages;
    state = state.copyWith(messagesByMatchId: updatedMap);
  }

  void scheduleCoffeeMeetup({
    required String matchId,
    required String senderId,
    required String receiverId,
    required String venueName,
    required String address,
    required DateTime scheduledTime,
  }) {
    final inviteMessage = Message(
      id: 'msg_coffee_${DateTime.now().microsecondsSinceEpoch}',
      matchId: matchId,
      senderId: senderId,
      receiverId: receiverId,
      content: '☕ Proposed Coffee Meetup at $venueName',
      timestamp: DateTime.now(),
      isRead: true,
      messageType: MessageType.coffeeMeetupInvite,
      meetupDetails: CoffeeMeetupDetails(
        venueName: venueName,
        address: address,
        scheduledTime: scheduledTime,
        status: MeetupStatus.pending,
      ),
    );

    // Sync to Supabase messages table in real-time
    _dbService?.sendChatMessage(inviteMessage);

    final currentMessages = List<Message>.from(state.messagesByMatchId[matchId] ?? []);
    currentMessages.add(inviteMessage);

    final updatedMap = Map<String, List<Message>>.from(state.messagesByMatchId);
    updatedMap[matchId] = currentMessages;
    state = state.copyWith(messagesByMatchId: updatedMap);
  }

  void updateMeetupStatus({
    required String matchId,
    required String messageId,
    required MeetupStatus newStatus,
  }) {
    final currentList = state.messagesByMatchId[matchId] ?? [];
    final updatedList = currentList.map((m) {
      if (m.id == messageId && m.meetupDetails != null) {
        return m.copyWith(
          meetupDetails: CoffeeMeetupDetails(
            venueName: m.meetupDetails!.venueName,
            address: m.meetupDetails!.address,
            scheduledTime: m.meetupDetails!.scheduledTime,
            status: newStatus,
          ),
        );
      }
      return m;
    }).toList();

    final updatedMap = Map<String, List<Message>>.from(state.messagesByMatchId);
    updatedMap[matchId] = updatedList;
    state = state.copyWith(messagesByMatchId: updatedMap);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final dbService = ref.watch(supabaseDatabaseProvider);
  return ChatNotifier(dbService);
});
