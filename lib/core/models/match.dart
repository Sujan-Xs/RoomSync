import 'user.dart';

class Match {
  final String id;
  final String userId;
  final String targetUserId;
  final User? targetUser;
  final double compatibilityScore; // 0.0 to 100.0
  final Map<String, double> scoreBreakdown;
  final bool isMutual;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  const Match({
    required this.id,
    required this.userId,
    required this.targetUserId,
    this.targetUser,
    required this.compatibilityScore,
    this.scoreBreakdown = const {},
    this.isMutual = false,
    this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
  });

  Match copyWith({
    String? id,
    String? userId,
    String? targetUserId,
    User? targetUser,
    double? compatibilityScore,
    Map<String, double>? scoreBreakdown,
    bool? isMutual,
    String? lastMessage,
    DateTime? lastMessageAt,
    DateTime? createdAt,
  }) {
    return Match(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetUserId: targetUserId ?? this.targetUserId,
      targetUser: targetUser ?? this.targetUser,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      scoreBreakdown: scoreBreakdown ?? this.scoreBreakdown,
      isMutual: isMutual ?? this.isMutual,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'targetUserId': targetUserId,
      'targetUser': targetUser?.toJson(),
      'compatibilityScore': compatibilityScore,
      'scoreBreakdown': scoreBreakdown,
      'isMutual': isMutual,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String,
      userId: json['userId'] as String,
      targetUserId: json['targetUserId'] as String,
      targetUser: json['targetUser'] != null ? User.fromJson(json['targetUser'] as Map<String, dynamic>) : null,
      compatibilityScore: (json['compatibilityScore'] as num).toDouble(),
      scoreBreakdown: (json['scoreBreakdown'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {},
      isMutual: json['isMutual'] as bool? ?? false,
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] != null ? DateTime.parse(json['lastMessageAt'] as String) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    );
  }
}

