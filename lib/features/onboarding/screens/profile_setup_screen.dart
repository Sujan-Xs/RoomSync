import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/lifestyle_habits.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/user_profile_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const ProfileSetupScreen({super.key, required this.onComplete});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Basic Info
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _bioController;
  String _gender = 'Female';
  String _avatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80';

  // Step 2: Budget & Location
  RangeValues _budget = const RangeValues(600, 1800);
  late final TextEditingController _cityController;
  final List<String> _preferredNeighborhoods = ['Williamsburg', 'Greenpoint', 'Bushwick'];
  final TextEditingController _neighborhoodInput = TextEditingController();

  // Step 3: Schedule & Habits
  String _bedtime = '11:00 PM';
  String _wakeTime = '07:00 AM';
  SleepScheduleType _chronotype = SleepScheduleType.flexible;
  int _cleanliness = 4;

  // Step 4: Dealbreakers
  SmokingPreference _smoking = SmokingPreference.nonSmoker;
  String _drinking = 'Socially';
  PetPreference _pets = PetPreference.petFriendly;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: initial.name);
    _ageController = TextEditingController(text: initial.age.toString());
    _bioController = TextEditingController(text: initial.bio);
    _gender = initial.gender;
    _avatarUrl = initial.avatarUrl;
    _budget = RangeValues(initial.habits.budgetMin, initial.habits.budgetMax);
    _cityController = TextEditingController(text: initial.location);
    _bedtime = initial.habits.bedtime;
    _wakeTime = initial.habits.wakeTime;
    _chronotype = initial.habits.sleepSchedule;
    _cleanliness = initial.habits.cleanlinessRating;
    _smoking = initial.habits.smoking;
    _drinking = initial.habits.drinkingHabit;
    _pets = initial.habits.petPreference;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _neighborhoodInput.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 280), curve: Curves.easeInOut);
    }
  }

  Future<void> _finish() async {
    final habits = LifestyleHabits(
      cleanlinessRating: _cleanliness,
      bedtime: _bedtime,
      wakeTime: _wakeTime,
      sleepSchedule: _chronotype,
      smoking: _smoking,
      petPreference: _pets,
      budgetMin: _budget.start.roundToDouble(),
      budgetMax: _budget.end.roundToDouble(),
      drinkingHabit: _drinking,
    );

    await ref.read(userProfileProvider.notifier).saveProfile(
          name: _nameController.text.trim(),
          age: int.tryParse(_ageController.text.trim()) ?? 24,
          gender: _gender,
          occupation: 'Product Designer',
          bio: _bioController.text.trim(),
          avatarUrl: _avatarUrl,
          location: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : 'Brooklyn, NY',
          preferredLocations: _preferredNeighborhoods,
          habits: habits,
        );

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile Setup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: _currentStep > 0 ? IconButton(icon: const Icon(LucideIcons.arrowLeft), onPressed: _back) : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Step ${_currentStep + 1} of 4', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(_stepName(_currentStep), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / 4.0,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceMuted,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  _step1BasicInfo(),
                  _step2BudgetAndLocation(),
                  _step3ScheduleAndHabits(),
                  _step4Dealbreakers(),
                ],
              ),
            ),

            // Navigation Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(_currentStep == 3 ? 'Complete & Start Matching' : 'Continue', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stepName(int i) {
    switch (i) {
      case 0: return 'Basic Info';
      case 1: return 'Budget & Location';
      case 2: return 'Schedule & Cleanliness';
      case 3: return 'Dealbreakers';
      default: return '';
    }
  }

  // STEP 1: Basic Info
  Widget _step1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tell us about yourself', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Your photo and bio will be displayed to potential flatmates.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 24),

          // Photo Uploader Placeholder
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(_avatarUrl),
                  backgroundColor: AppColors.primaryLight,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.camera, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _field('Full Name', _nameController, LucideIcons.user),
          const SizedBox(height: 14),
          _field('Age', _ageController, LucideIcons.calendar, isNum: true),
          const SizedBox(height: 14),

          const Text('Gender', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            ),
            items: ['Female', 'Male', 'Non-binary', 'Prefer not to say'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: (v) => setState(() => _gender = v ?? 'Female'),
          ),
          const SizedBox(height: 14),

          _field('Bio', _bioController, LucideIcons.fileText, maxLines: 3),
        ],
      ),
    );
  }

  // STEP 2: Budget & Location
  Widget _step2BudgetAndLocation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Budget & Target Areas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('This accounts for 30% of the RoomSync matching algorithm.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 28),

          // Target Budget Range Display
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
              child: Text('\$${_budget.start.toInt()} – \$${_budget.end.toInt()} / mo', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
          ),
          const SizedBox(height: 20),
          RangeSlider(
            values: _budget,
            min: 500,
            max: 3500,
            divisions: 30,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _budget = v),
          ),
          const SizedBox(height: 24),

          _field('Primary City / Borough', _cityController, LucideIcons.mapPin),
          const SizedBox(height: 20),

          const Text('Preferred Neighborhoods', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _preferredNeighborhoods.map((n) {
              return Chip(
                label: Text(n),
                backgroundColor: AppColors.surface,
                deleteIcon: const Icon(LucideIcons.x, size: 14),
                onDeleted: () => setState(() => _preferredNeighborhoods.remove(n)),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _neighborhoodInput,
                  decoration: InputDecoration(
                    hintText: 'Add neighborhood (e.g. Astoria)',
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(LucideIcons.plusCircle, color: AppColors.primary),
                onPressed: () {
                  final text = _neighborhoodInput.text.trim();
                  if (text.isNotEmpty && !_preferredNeighborhoods.contains(text)) {
                    setState(() {
                      _preferredNeighborhoods.add(text);
                      _neighborhoodInput.clear();
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 3: Schedule & Habits
  Widget _step3ScheduleAndHabits() {
    final cleanlinessTitles = ['Relaxed (1/5)', 'Casual (2/5)', 'Balanced (3/5)', 'Organized (4/5)', 'Spotless (5/5)'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Living Rhythm & Cleanliness', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Sleep matching is weighted 25%; Cleanliness variance is weighted 25%.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 28),

          Row(
             children: [
               Expanded(child: _timeTile('Bedtime', _bedtime, LucideIcons.moon, (v) => setState(() => _bedtime = v))),
               const SizedBox(width: 12),
               Expanded(child: _timeTile('Wake Up', _wakeTime, LucideIcons.sun, (v) => setState(() => _wakeTime = v))),
             ],
          ),
          const SizedBox(height: 24),

          const Text('Chronotype', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              _chronotypeOption('Early Bird', SleepScheduleType.earlyBird, LucideIcons.sunrise),
              const SizedBox(width: 8),
              _chronotypeOption('Flexible', SleepScheduleType.flexible, LucideIcons.clock),
              const SizedBox(width: 8),
              _chronotypeOption('Night Owl', SleepScheduleType.nightOwl, LucideIcons.moon),
            ],
          ),
          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cleanliness / Chore Standard', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text(cleanlinessTitles[_cleanliness - 1], style: const TextStyle(color: AppColors.scoreHigh, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          Slider(
            value: _cleanliness.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: AppColors.scoreHigh,
            onChanged: (v) => setState(() => _cleanliness = v.toInt()),
          ),
        ],
      ),
    );
  }

  // STEP 4: Dealbreakers
  Widget _step4Dealbreakers() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dealbreaker Preferences', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Conflicts trigger automatic compatibility penalties to protect your comfort.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 24),

          const Text('Smoking Habit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _choiceTile('Smoke-free home (Non-smoker)', _smoking == SmokingPreference.nonSmoker, () => setState(() => _smoking = SmokingPreference.nonSmoker)),
          _choiceTile('Outdoors only (Balcony/Patio)', _smoking == SmokingPreference.outsideOnly, () => setState(() => _smoking = SmokingPreference.outsideOnly)),
          _choiceTile('Smoker', _smoking == SmokingPreference.smoker, () => setState(() => _smoking = SmokingPreference.smoker)),

          const SizedBox(height: 20),
          const Text('Drinking Habits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _choiceTile('Never / Non-drinker', _drinking == 'Never', () => setState(() => _drinking = 'Never')),
          _choiceTile('Socially / Weekends', _drinking == 'Socially', () => setState(() => _drinking = 'Socially')),
          _choiceTile('Regularly', _drinking == 'Regularly', () => setState(() => _drinking = 'Regularly')),

          const SizedBox(height: 20),
          const Text('Pets Preference', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _choiceTile('Pet Friendly (Dogs & Cats welcome)', _pets == PetPreference.petFriendly, () => setState(() => _pets = PetPreference.petFriendly)),
          _choiceTile('I have a Dog', _pets == PetPreference.hasDog, () => setState(() => _pets = PetPreference.hasDog)),
          _choiceTile('I have a Cat', _pets == PetPreference.hasCat, () => setState(() => _pets = PetPreference.hasCat)),
          _choiceTile('No Pets allowed', _pets == PetPreference.noPets, () => setState(() => _pets = PetPreference.noPets)),
          _choiceTile('Severe Pet Allergy (Strict dealbreaker)', _pets == PetPreference.allergic, () => setState(() => _pets = PetPreference.allergic)),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon, {bool isNum = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          ),
        ),
      ],
    );
  }

  Widget _timeTile(String title, String currentVal, IconData icon, ValueChanged<String> onSelect) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 14, color: AppColors.primary), const SizedBox(width: 6), Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))]),
          const SizedBox(height: 6),
          DropdownButton<String>(
            value: currentVal,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: ['09:00 PM', '10:00 PM', '10:30 PM', '11:00 PM', '11:30 PM', '12:00 AM', '01:00 AM', '05:00 AM', '06:00 AM', '06:30 AM', '07:00 AM', '07:30 AM', '08:00 AM', '09:00 AM']
                .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))).toList(),
            onChanged: (v) { if (v != null) onSelect(v); },
          ),
        ],
      ),
    );
  }

  Widget _chronotypeOption(String title, SleepScheduleType type, IconData icon) {
    final selected = _chronotype == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _chronotype = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 18),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: selected ? AppColors.primary : AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _choiceTile(String title, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(selected ? LucideIcons.checkCircle2 : LucideIcons.circle, color: selected ? AppColors.primary : AppColors.textTertiary, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}

