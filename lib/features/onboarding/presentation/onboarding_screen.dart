import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/lifestyle_habits.dart';
import '../../../core/theme/app_colors.dart';
import '../../matching/controllers/match_controller.dart';
import '../providers/user_profile_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({
    super.key,
    required this.onFinish,
  });

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Profile Info
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _occupationController;
  late final TextEditingController _locationController;

  // Step 2: Budget Slider
  RangeValues _budgetRange = const RangeValues(1100.0, 1650.0);

  // Step 3: Sleep Hours
  String _bedtime = '11:00 PM';
  String _wakeTime = '07:00 AM';
  SleepScheduleType _sleepSchedule = SleepScheduleType.flexible;

  // Step 4: Cleanliness Scale (1 to 5)
  int _cleanlinessRating = 4;

  // Step 5: Smoking & Pets
  SmokingPreference _smoking = SmokingPreference.nonSmoker;
  PetPreference _petPreference = PetPreference.petFriendly;

  @override
  void initState() {
    super.initState();
    final user = ref.read(matchProvider).currentUser;
    _nameController = TextEditingController(text: user.name);
    _ageController = TextEditingController(text: user.age.toString());
    _occupationController = TextEditingController(text: user.occupation);
    _locationController = TextEditingController(text: user.location);
    _budgetRange = RangeValues(user.habits.budgetMin, user.habits.budgetMax);
    _bedtime = user.habits.bedtime;
    _wakeTime = user.habits.wakeTime;
    _sleepSchedule = user.habits.sleepSchedule;
    _cleanlinessRating = user.habits.cleanlinessRating;
    _smoking = user.habits.smoking;
    _petPreference = user.habits.petPreference;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _saveProfile() {
    final currentUser = ref.read(userProfileProvider);
    final updatedHabits = LifestyleHabits(
      cleanlinessRating: _cleanlinessRating,
      bedtime: _bedtime,
      wakeTime: _wakeTime,
      sleepSchedule: _sleepSchedule,
      smoking: _smoking,
      petPreference: _petPreference,
      budgetMin: _budgetRange.start.roundToDouble(),
      budgetMax: _budgetRange.end.roundToDouble(),
      dietaryPreference: currentUser.habits.dietaryPreference,
      workSchedule: currentUser.habits.workSchedule,
      drinkingHabit: currentUser.habits.drinkingHabit,
    );

    final newName = _nameController.text.trim();
    final newAge = int.tryParse(_ageController.text.trim()) ?? 25;
    final newOccupation = _occupationController.text.trim();
    final newLocation = _locationController.text.trim();

    ref.read(userProfileProvider.notifier).saveProfile(
          name: newName.isNotEmpty ? newName : currentUser.name,
          age: newAge,
          gender: currentUser.gender,
          occupation: newOccupation.isNotEmpty ? newOccupation : currentUser.occupation,
          bio: currentUser.bio,
          avatarUrl: currentUser.avatarUrl,
          location: newLocation.isNotEmpty ? newLocation : currentUser.location,
          preferredLocations: currentUser.preferredLocations,
          habits: updatedHabits,
        );

    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profile & Habit Wizard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${_currentStep + 1} of 5',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        _getStepTitle(_currentStep),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / 5.0,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceMuted,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            // Step Content Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildStep1PersonalInfo(),
                  _buildStep2BudgetSlider(),
                  _buildStep3SleepSchedule(),
                  _buildStep4CleanlinessScale(),
                  _buildStep5SmokingAndPets(),
                ],
              ),
            ),

            // Bottom Continue / Save Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  child: Text(_currentStep == 4 ? 'Save & Discover Flatmates' : 'Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Personal Info';
      case 1:
        return 'Monthly Budget';
      case 2:
        return 'Sleep Window';
      case 3:
        return 'Cleanliness Scale';
      case 4:
        return 'Smoking & Pets';
      default:
        return '';
    }
  }

  // STEP 1: Personal Info
  Widget _buildStep1PersonalInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Let's set up your profile",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'This info helps flatmates get to know you and your lifestyle.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          _buildTextField('Full Name', _nameController, LucideIcons.user),
          const SizedBox(height: 16),
          _buildTextField('Age', _ageController, LucideIcons.calendar, isNumber: true),
          const SizedBox(height: 16),
          _buildTextField('Occupation', _occupationController, LucideIcons.briefcase),
          const SizedBox(height: 16),
          _buildTextField('Current Location / Target City', _locationController, LucideIcons.mapPin),
        ],
      ),
    );
  }

  // STEP 2: Budget Slider
  Widget _buildStep2BudgetSlider() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's your monthly rent budget?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select your target range per room (utilities included).',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 48),

          // Budget Indicator Display
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Text(
                '\$${_budgetRange.start.toInt()} – \$${_budgetRange.end.toInt()} / mo',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),

          RangeSlider(
            values: _budgetRange,
            min: 500,
            max: 3500,
            divisions: 60,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.surfaceMuted,
            onChanged: (values) {
              setState(() {
                _budgetRange = values;
              });
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$500', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                Text('\$2,000', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                Text('\$3,500+', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3: Sleep Hours & Chronotype
  Widget _buildStep3SleepSchedule() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's your sleep rhythm?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Roommates with compatible schedules report 70% fewer quiet-hour disputes.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          // Bedtime & Wake Time Selectors
          Row(
            children: [
              Expanded(
                child: _buildTimePickerTile(
                  title: 'Typical Bedtime',
                  timeStr: _bedtime,
                  icon: LucideIcons.moon,
                  onChanged: (newVal) => setState(() => _bedtime = newVal),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimePickerTile(
                  title: 'Wake Time',
                  timeStr: _wakeTime,
                  icon: LucideIcons.sun,
                  onChanged: (newVal) => setState(() => _wakeTime = newVal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          const Text(
            'Chronotype',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildChronotypeChoice('Early Bird', SleepScheduleType.earlyBird, LucideIcons.sunrise),
              const SizedBox(width: 10),
              _buildChronotypeChoice('Flexible', SleepScheduleType.flexible, LucideIcons.clock),
              const SizedBox(width: 10),
              _buildChronotypeChoice('Night Owl', SleepScheduleType.nightOwl, LucideIcons.moon),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 4: Cleanliness Scale (1 to 5)
  Widget _buildStep4CleanlinessScale() {
    final descriptions = [
      'Relaxed — Chores get done eventually, unbothered by clutter.',
      'Easygoing — Casual approach, clean on weekends.',
      'Balanced — Tidy common areas, daily dish cleanup.',
      'Organized — Structured routine, high hygiene expectation.',
      'Spotless — Extremely neat, sparkling kitchen and bathrooms at all times.',
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "How clean do you keep your flat?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cleanliness variance is weighted 25% in the RoomSync algorithm.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 36),

          // Large rating badge
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isFilled = index < _cleanlinessRating;
                    return IconButton(
                      icon: Icon(
                        LucideIcons.sparkles,
                        size: 36,
                        color: isFilled ? AppColors.scoreHigh : AppColors.surfaceMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _cleanlinessRating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_cleanlinessRating} of 5 Rating',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.scoreHigh,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Description Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.info, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    descriptions[_cleanlinessRating - 1],
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 5: Smoking & Pets Dealbreaker Toggles
  Widget _buildStep5SmokingAndPets() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Smoking & Pet Preferences",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'These are evaluated as compatibility dealbreakers to prevent friction.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          const Text('Smoking Habit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildSmokingOption('Non-smoker (Smoke-free home)', SmokingPreference.nonSmoker),
          _buildSmokingOption('Outside only (Balcony / Terrace)', SmokingPreference.outsideOnly),
          _buildSmokingOption('Smoker', SmokingPreference.smoker),

          const SizedBox(height: 24),
          const Text('Pets Preference', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildPetOption('Pet-friendly (Love dogs & cats)', PetPreference.petFriendly),
          _buildPetOption('I have a Dog', PetPreference.hasDog),
          _buildPetOption('I have a Cat', PetPreference.hasCat),
          _buildPetOption('No pets allowed', PetPreference.noPets),
          _buildPetOption('Severe Pet Allergy (Strict dealbreaker)', PetPreference.allergic),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickerTile({
    required String title,
    required String timeStr,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: timeStr,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: [
              '09:00 PM', '10:00 PM', '10:30 PM', '11:00 PM', '11:30 PM',
              '12:00 AM', '01:00 AM', '02:00 AM',
              '05:00 AM', '06:00 AM', '06:30 AM', '07:00 AM', '07:30 AM', '08:00 AM', '09:00 AM', '10:00 AM'
            ].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChronotypeChoice(String title, SleepScheduleType type, IconData icon) {
    final isSelected = _sleepSchedule == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _sleepSchedule = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmokingOption(String title, SmokingPreference pref) {
    final isSelected = _smoking == pref;
    return GestureDetector(
      onTap: () => setState(() => _smoking = pref),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }

  Widget _buildPetOption(String title, PetPreference pref) {
    final isSelected = _petPreference == pref;
    return GestureDetector(
      onTap: () => setState(() => _petPreference = pref),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}

