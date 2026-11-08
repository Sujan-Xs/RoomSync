import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/apartment.dart';
import 'mock_data_service.dart';

class ApartmentService {
  static final List<Apartment> mockApartments = [
    // 1. Williamsburg Loft (Hosted by Elena)
    Apartment(
      id: 'apt_01',
      title: 'Sun-drenched Loft with High Ceilings & Skylights',
      neighborhood: 'Williamsburg',
      city: 'Brooklyn, NY',
      monthlyRent: 1450.0,
      bedrooms: 2,
      bathrooms: 1,
      isFurnished: true,
      billsIncluded: false,
      availableFrom: DateTime.now().add(const Duration(days: 15)),
      amenities: ['In-unit Washer/Dryer', 'Rooftop Access', 'Dishwasher', 'Natural Light', 'Central AC'],
      imageUrls: [
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=1000&q=80',
      ],
      description: 'Massive open-concept living area with 14ft wood-beamed ceilings and polished concrete floors. Private bedroom with large closet. 4 minute walk to the Bedford L train.',
      host: MockDataService.mockProfiles[0], // Elena
    ),

    // 2. Greenpoint Brownstone (Hosted by Liam)
    Apartment(
      id: 'apt_02',
      title: 'Historic Brownstone with Private Backyard & Patio',
      neighborhood: 'Greenpoint',
      city: 'Brooklyn, NY',
      monthlyRent: 1550.0,
      bedrooms: 3,
      bathrooms: 2,
      isFurnished: false,
      billsIncluded: true,
      availableFrom: DateTime.now().add(const Duration(days: 20)),
      amenities: ['Private Garden', 'Pet Friendly', 'Exposed Brick', 'Eat-in Kitchen', 'Hardwood Floors'],
      imageUrls: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1000&q=80',
      ],
      description: 'Charming tree-lined street right next to Transmitter Park. Huge private backyard perfect for dogs and weekend barbecues. High-speed fiber internet and heat/hot water included.',
      host: MockDataService.mockProfiles[3], // Liam
    ),

    // 3. FiDi Luxury High-Rise (Hosted by Marcus)
    Apartment(
      id: 'apt_03',
      title: 'Luxury 42nd-Floor Corner 2BR with Harbor Views',
      neighborhood: 'Financial District',
      city: 'Manhattan, NY',
      monthlyRent: 2200.0,
      bedrooms: 2,
      bathrooms: 2,
      isFurnished: true,
      billsIncluded: false,
      availableFrom: DateTime.now().add(const Duration(days: 10)),
      amenities: ['24/7 Doorman', 'Fitness Center', 'Indoor Pool', 'Elevator', 'Lounge'],
      imageUrls: [
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1000&q=80',
      ],
      description: 'Floor-to-ceiling windows overlooking the Hudson River. En-suite marble bathroom, full chef kitchen with Sub-Zero appliances, and state-of-the-art building amenities.',
      host: MockDataService.mockProfiles[1], // Marcus
    ),

    // 4. Cobble Hill Pre-War (Hosted by Sofia)
    Apartment(
      id: 'apt_04',
      title: 'Classic Pre-War 2BR near Brooklyn Bridge Park',
      neighborhood: 'Cobble Hill',
      city: 'Brooklyn, NY',
      monthlyRent: 1650.0,
      bedrooms: 2,
      bathrooms: 1,
      isFurnished: false,
      billsIncluded: false,
      availableFrom: DateTime.now().add(const Duration(days: 30)),
      amenities: ['Balcony', 'Dishwasher', 'Laundry in Building', 'Quiet Street'],
      imageUrls: [
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=1000&q=80',
      ],
      description: 'Located in the heart of Cobble Hill on a picturesque cobblestone lane. Walking distance to great wine bars, artisan bakeries, and multiple subway lines (F/G/R/2/3).',
      host: MockDataService.mockProfiles[4], // Sofia
    ),

    // 5. Bushwick Duplex (Hosted by Kai)
    Apartment(
      id: 'apt_05',
      title: 'Creative Artist Duplex with Rooftop Deck Access',
      neighborhood: 'Bushwick',
      city: 'Brooklyn, NY',
      monthlyRent: 1100.0,
      bedrooms: 3,
      bathrooms: 1,
      isFurnished: true,
      billsIncluded: true,
      availableFrom: DateTime.now().add(const Duration(days: 5)),
      amenities: ['Rooftop Deck', 'Music Friendly', 'High Ceilings', 'Subway Nearby'],
      imageUrls: [
        'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?auto=format&fit=crop&w=1000&q=80',
      ],
      description: 'Spacious creative hub 2 blocks from the Jefferson L train. Massive private rooftop overlooking the Manhattan skyline. All utilities included in rent.',
      host: MockDataService.mockProfiles[5], // Kai
    ),
  ];

  static Future<List<Apartment>> fetchApartments() async {
    try {
      final client = Supabase.instance.client;
      final res = await client.from('apartments').select();
      final list = (res as List<dynamic>).map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        final hostId = map['host_user_id'];
        final host = MockDataService.mockProfiles.firstWhere(
          (u) => u.id == hostId,
          orElse: () => MockDataService.mockProfiles.first,
        );
        map['host'] = host.toJson();
        return Apartment.fromJson(map);
      }).toList();
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return mockApartments;
  }
}

