enum MessageType { text, coffeeMeetupInvite, system }

enum MeetupStatus { pending, accepted, declined }

class CoffeeMeetupDetails {
  final String venueName;
  final String address;
  final DateTime scheduledTime;
  final MeetupStatus status;

  const CoffeeMeetupDetails({
    required this.venueName,
    required this.address,
    required this.scheduledTime,
    this.status = MeetupStatus.pending,
  });

  Map<String, dynamic> toJson() {
    return {
      'venueName': venueName,
      'address': address,
      'scheduledTime': scheduledTime.toIso8601String(),
      'status': status.name,
    };
  }

  factory CoffeeMeetupDetails.fromJson(Map<String, dynamic> json) {
    return CoffeeMeetupDetails(
      venueName: json['venueName'] as String,
      address: json['address'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      status: MeetupStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MeetupStatus.pending,
      ),
    );
  }
}

class Message {
  final String id;
  final String matchId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageType messageType;
  final CoffeeMeetupDetails? meetupDetails;

  const Message({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.messageType = MessageType.text,
    this.meetupDetails,
  });

  Message copyWith({
    String? id,
    String? matchId,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageType? messageType,
    CoffeeMeetupDetails? meetupDetails,
  }) {
    return Message(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      messageType: messageType ?? this.messageType,
      meetupDetails: meetupDetails ?? this.meetupDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchId': matchId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'messageType': messageType.name,
      'meetupDetails': meetupDetails?.toJson(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      messageType: MessageType.values.firstWhere(
        (e) => e.name == json['messageType'],
        orElse: () => MessageType.text,
      ),
      meetupDetails: json['meetupDetails'] != null
          ? CoffeeMeetupDetails.fromJson(json['meetupDetails'] as Map<String, dynamic>)
          : null,
    );
  }
}

