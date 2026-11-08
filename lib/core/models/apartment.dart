import 'user.dart';

class Apartment {
  final String id;
  final String title;
  final String neighborhood;
  final String city;
  final double monthlyRent;
  final int bedrooms;
  final int bathrooms;
  final bool isFurnished;
  final bool billsIncluded;
  final DateTime availableFrom;
  final List<String> amenities;
  final List<String> imageUrls;
  final String description;
  final User host;

  const Apartment({
    required this.id,
    required this.title,
    required this.neighborhood,
    this.city = 'New York, NY',
    required this.monthlyRent,
    required this.bedrooms,
    required this.bathrooms,
    required this.isFurnished,
    required this.billsIncluded,
    required this.availableFrom,
    required this.amenities,
    required this.imageUrls,
    required this.description,
    required this.host,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'neighborhood': neighborhood,
      'city': city,
      'monthlyRent': monthlyRent,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'isFurnished': isFurnished,
      'billsIncluded': billsIncluded,
      'availableFrom': availableFrom.toIso8601String(),
      'amenities': amenities,
      'imageUrls': imageUrls,
      'description': description,
      'host': host.toJson(),
    };
  }

  factory Apartment.fromJson(Map<String, dynamic> json) {
    return Apartment(
      id: json['id'] as String,
      title: json['title'] as String,
      neighborhood: json['neighborhood'] as String,
      city: json['city'] as String? ?? 'New York, NY',
      monthlyRent: (json['monthlyRent'] as num).toDouble(),
      bedrooms: (json['bedrooms'] as num).toInt(),
      bathrooms: (json['bathrooms'] as num).toInt(),
      isFurnished: json['isFurnished'] as bool? ?? false,
      billsIncluded: json['billsIncluded'] as bool? ?? false,
      availableFrom: DateTime.parse(json['availableFrom'] as String),
      amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      description: json['description'] as String? ?? '',
      host: User.fromJson(json['host'] as Map<String, dynamic>),
    );
  }
}

