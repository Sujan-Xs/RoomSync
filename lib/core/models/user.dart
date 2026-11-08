import 'lifestyle_habits.dart';

class User {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String occupation;
  final String bio;
  final String avatarUrl;
  final List<String> imageUrls;
  final bool isVerified;
  final String location;
  final List<String> preferredLocations;
  final LifestyleHabits habits;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.occupation,
    required this.bio,
    required this.avatarUrl,
    required this.imageUrls,
    required this.isVerified,
    required this.location,
    required this.preferredLocations,
    required this.habits,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? occupation,
    String? bio,
    String? avatarUrl,
    List<String>? imageUrls,
    bool? isVerified,
    String? location,
    List<String>? preferredLocations,
    LifestyleHabits? habits,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      isVerified: isVerified ?? this.isVerified,
      location: location ?? this.location,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      habits: habits ?? this.habits,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'occupation': occupation,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'imageUrls': imageUrls,
      'isVerified': isVerified,
      'location': location,
      'preferredLocations': preferredLocations,
      'habits': habits.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String? ?? 'Not specified',
      occupation: json['occupation'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      isVerified: json['isVerified'] as bool? ?? false,
      location: json['location'] as String? ?? '',
      preferredLocations: (json['preferredLocations'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      habits: LifestyleHabits.fromJson(json['habits'] as Map<String, dynamic>),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    );
  }
}

