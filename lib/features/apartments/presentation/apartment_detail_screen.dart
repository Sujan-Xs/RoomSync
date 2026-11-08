import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/apartment.dart';
import '../../../core/services/compatibility_calculator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/compatibility_badge.dart';
import '../../../core/widgets/habit_comparison_chip.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../chat/screens/chat_detail_screen.dart';
import '../../matching/controllers/match_controller.dart';

class ApartmentDetailScreen extends ConsumerStatefulWidget {
  final Apartment apartment;

  const ApartmentDetailScreen({super.key, required this.apartment});

  @override
  ConsumerState<ApartmentDetailScreen> createState() => _ApartmentDetailScreenState();
}

class _ApartmentDetailScreenState extends ConsumerState<ApartmentDetailScreen> {
  int _activeImageIndex = 0;
  bool _isSaved = false;

  void _showScheduleMeetupModal(BuildContext context) {
    final host = widget.apartment.host;
    final currentUser = ref.read(matchProvider).currentUser;
    final matchId = 'match_${currentUser.id}_${host.id}';

    final venueController = TextEditingController(text: 'Devoción Coffee Roasters');
    final addressController = TextEditingController(text: '69 Grand St, Williamsburg');
    DateTime selectedDateTime = DateTime.now().add(const Duration(days: 2, hours: 2));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.coffeeSafety.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.coffee, color: AppColors.coffeeSafety, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Propose Public Meetup with ${host.name}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            const Text(
                              'Always meet in public before touring apartments',
                              style: TextStyle(fontSize: 12, color: AppColors.coffeeSafety, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Public Venue / Coffee Shop', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: venueController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(LucideIcons.mapPin, size: 18, color: AppColors.primary),
                      hintText: 'e.g. Local Cafe or Library',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Address / Neighborhood', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(LucideIcons.navigation, size: 18, color: AppColors.primary),
                      hintText: 'e.g. 123 Main St',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDateTime,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (pickedDate != null && context.mounted) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                        );
                        if (pickedTime != null) {
                          setModalState(() {
                            selectedDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.calendar, size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('EEE, MMM d, yyyy • h:mm a').format(selectedDateTime),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(chatProvider.notifier).scheduleCoffeeMeetup(
                              matchId: matchId,
                              senderId: currentUser.id,
                              receiverId: host.id,
                              venueName: venueController.text.trim(),
                              address: addressController.text.trim(),
                              scheduledTime: selectedDateTime,
                            );
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Meetup proposed to ${host.name}!'),
                            backgroundColor: AppColors.coffeeSafety,
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.send, size: 18),
                      label: const Text('Send Safe Meetup Invite', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coffeeSafety,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apt = widget.apartment;
    final host = apt.host;
    final currentUser = ref.watch(matchProvider).currentUser;
    final compResult = CompatibilityCalculator.calculate(currentUser, host);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero Gallery App Bar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: IconButton(
                    icon: Icon(
                      _isSaved ? LucideIcons.bookmarkCheck : LucideIcons.bookmark,
                      color: _isSaved ? AppColors.accent : Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _isSaved = !_isSaved);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isSaved ? 'Listing saved to favorites!' : 'Removed from saved listings.'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: apt.imageUrls.length,
                    onPageChanged: (i) => setState(() => _activeImageIndex = i),
                    itemBuilder: (ctx, index) {
                      return Image.network(
                        apt.imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.border,
                          child: const Icon(LucideIcons.image, size: 60, color: AppColors.textTertiary),
                        ),
                      );
                    },
                  ),
                  // Image index indicator
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_activeImageIndex + 1} / ${apt.imageUrls.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price and Utilities Tag
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$${apt.monthlyRent.toInt()}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      const Text(
                        ' / month',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: apt.billsIncluded
                              ? AppColors.scoreHigh.withOpacity(0.12)
                              : AppColors.textTertiary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          apt.billsIncluded ? '✓ Bills Included' : 'Bills Separate',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: apt.billsIncluded ? AppColors.scoreHigh : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title & Location
                  Text(
                    apt.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${apt.neighborhood}, ${apt.city}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quick Spec Badges
                  Row(
                    children: [
                      _buildSpecPill(LucideIcons.bedDouble, '${apt.bedrooms} Bed'),
                      const SizedBox(width: 8),
                      _buildSpecPill(LucideIcons.bath, '${apt.bathrooms} Bath'),
                      const SizedBox(width: 8),
                      _buildSpecPill(
                        LucideIcons.sofa,
                        apt.isFurnished ? 'Furnished' : 'Unfurnished',
                      ),
                      const SizedBox(width: 8),
                      _buildSpecPill(
                        LucideIcons.calendar,
                        'Avail ${DateFormat('MMM d').format(apt.availableFrom)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // About the Space
                  const Text(
                    'About this home',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    apt.description,
                    style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Amenities Grid
                  const Text(
                    'Amenities & Perks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: apt.amenities.map((amenity) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.check, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              amenity,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // Roommate / Host Card
                  const Text(
                    'Your Future Flatmate',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage(host.avatarUrl),
                                ),
                                if (host.isVerified)
                                  const Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: VerifiedBadge(size: 16),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${host.name}, ${host.age}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ),
                                      if (host.isVerified) ...[
                                        const SizedBox(width: 6),
                                        const VerifiedBadge(size: 14),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    host.occupation,
                                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            CompatibilityBadge(score: compResult.overallScore, size: 48),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          host.bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            HabitComparisonChip(
                              label: 'Cleanliness ${host.habits.cleanlinessRating}/5',
                              icon: LucideIcons.sparkles,
                              isAligned: host.habits.cleanlinessRating >= currentUser.habits.cleanlinessRating - 1,
                            ),
                            HabitComparisonChip(
                              label: host.habits.smoking == SmokingPreference.nonSmoker ? 'Non-smoker' : 'Smoker',
                              icon: LucideIcons.cigarette,
                              isAligned: host.habits.smoking == currentUser.habits.smoking,
                            ),
                            HabitComparisonChip(
                              label: host.habits.petPreference == PetPreference.petFriendly ? 'Pet Friendly' : 'No Pets',
                              icon: LucideIcons.dog,
                              isAligned: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Spacing for sticky bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Propose Coffee Meetup safety button
              IconButton.filledTonal(
                onPressed: () => _showScheduleMeetupModal(context),
                icon: const Icon(LucideIcons.coffee, color: AppColors.coffeeSafety),
                tooltip: 'Propose Public Meetup',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.coffeeSafety.withOpacity(0.12),
                  padding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(width: 12),
              // Message Host CTA
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final matchId = 'match_${currentUser.id}_${host.id}';
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            matchId: matchId,
                            targetUser: host,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.messageSquare, size: 18),
                    label: Text(
                      'Chat with ${host.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecPill(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

