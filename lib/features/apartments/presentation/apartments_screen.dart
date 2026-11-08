import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/apartment.dart';
import '../../../core/services/apartment_service.dart';
import '../../../core/services/compatibility_calculator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/compatibility_badge.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../matching/controllers/match_controller.dart';
import 'apartment_detail_screen.dart';

class ApartmentsScreen extends ConsumerStatefulWidget {
  const ApartmentsScreen({super.key});

  @override
  ConsumerState<ApartmentsScreen> createState() => _ApartmentsScreenState();
}

class _ApartmentsScreenState extends ConsumerState<ApartmentsScreen> {
  String _selectedNeighborhood = 'All';
  double _maxRent = 3000.0;
  bool _furnishedOnly = false;
  bool _billsIncludedOnly = false;
  List<Apartment> _apartments = ApartmentService.mockApartments;

  @override
  void initState() {
    super.initState();
    _loadApartments();
  }

  Future<void> _loadApartments() async {
    final list = await ApartmentService.fetchApartments();
    if (mounted) setState(() => _apartments = list);
  }

  final List<String> _neighborhoods = ['All', 'Williamsburg', 'Greenpoint', 'Bushwick', 'Cobble Hill', 'Financial District'];

  List<Apartment> _filterApartments(List<Apartment> apartments) {
    return apartments.where((apt) {
      if (_selectedNeighborhood != 'All' && apt.neighborhood != _selectedNeighborhood) {
        return false;
      }
      if (apt.monthlyRent > _maxRent) {
        return false;
      }
      if (_furnishedOnly && !apt.isFurnished) {
        return false;
      }
      if (_billsIncludedOnly && !apt.billsIncluded) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(matchProvider).currentUser;
    final filteredApartments = _filterApartments(_apartments);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Filter Chips Horizontal Scroll
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Neighborhood dropdown chip
                  ..._neighborhoods.map((n) {
                    final isSelected = _selectedNeighborhood == n;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(n),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedNeighborhood = n;
                          });
                        },
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                        backgroundColor: AppColors.background,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    );
                  }),
                  // Furnished filter
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('Furnished'),
                      selected: _furnishedOnly,
                      onSelected: (selected) {
                        setState(() {
                          _furnishedOnly = selected;
                        });
                      },
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _furnishedOnly ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: _furnishedOnly ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                      backgroundColor: AppColors.background,
                      side: BorderSide(
                        color: _furnishedOnly ? AppColors.primary : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  // Bills Included filter
                  FilterChip(
                    label: const Text('Bills Included'),
                    selected: _billsIncludedOnly,
                    onSelected: (selected) {
                      setState(() {
                        _billsIncludedOnly = selected;
                      });
                    },
                    selectedColor: AppColors.primaryLight,
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _billsIncludedOnly ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: _billsIncludedOnly ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                    backgroundColor: AppColors.background,
                    side: BorderSide(
                      color: _billsIncludedOnly ? AppColors.primary : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Apartment Cards List
          Expanded(
            child: filteredApartments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.home, size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 12),
                        const Text(
                          'No apartments match your filters',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedNeighborhood = 'All';
                              _furnishedOnly = false;
                              _billsIncludedOnly = false;
                            });
                          },
                          child: const Text('Reset Apartment Filters'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredApartments.length,
                    itemBuilder: (ctx, index) {
                      final apt = filteredApartments[index];
                      final host = apt.host;
                      final compScore = CompatibilityCalculator.calculate(currentUser, host).overallScore;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ApartmentDetailScreen(apartment: apt),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image Header with overlays
                              Stack(
                                children: [
                                  AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Image.network(
                                      apt.imageUrls.first,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: AppColors.border,
                                        child: const Icon(LucideIcons.image, size: 40, color: AppColors.textTertiary),
                                      ),
                                    ),
                                  ),
                                  // Rent badge
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.75),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '\$${apt.monthlyRent.toInt()}/mo',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Furnished Pill
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        apt.isFurnished ? 'Furnished' : 'Unfurnished',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Info Section
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title & Neighborhood
                                    Text(
                                      apt.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(LucideIcons.mapPin, size: 14, color: AppColors.primary),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${apt.neighborhood}, ${apt.city} • ${apt.bedrooms} Bed, ${apt.bathrooms} Bath',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Host Flatmate row
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: AppColors.border.withOpacity(0.6)),
                                      ),
                                      child: Row(
                                        children: [
                                          Stack(
                                            children: [
                                              CircleAvatar(
                                                radius: 18,
                                                backgroundImage: NetworkImage(host.avatarUrl),
                                              ),
                                              if (host.isVerified)
                                                const Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: VerifiedBadge(size: 12),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Flatmate: ${host.name}',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                ),
                                                Text(
                                                  host.occupation,
                                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                                ),
                                              ],
                                            ),
                                          ),
                                          CompatibilityBadge(score: compScore, size: 38),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

