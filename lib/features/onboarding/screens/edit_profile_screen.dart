import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/lifestyle_habits.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/user_profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _occupationController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;
  late RangeValues _budget;
  late int _cleanliness;
  late String _bedtime;
  late String _wakeTime;
  late SmokingPreference _smoking;
  late String _drinking;
  late PetPreference _pets;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: user.name);
    _ageController = TextEditingController(text: user.age.toString());
    _occupationController = TextEditingController(text: user.occupation);
    _bioController = TextEditingController(text: user.bio);
    _locationController = TextEditingController(text: user.location);
    _budget = RangeValues(user.habits.budgetMin, user.habits.budgetMax);
    _cleanliness = user.habits.cleanlinessRating;
    _bedtime = user.habits.bedtime;
    _wakeTime = user.habits.wakeTime;
    _smoking = user.habits.smoking;
    _drinking = user.habits.drinkingHabit;
    _pets = user.habits.petPreference;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final currentUser = ref.read(userProfileProvider);
    final updatedHabits = currentUser.habits.copyWith(
      budgetMin: _budget.start.roundToDouble(),
      budgetMax: _budget.end.roundToDouble(),
      cleanlinessRating: _cleanliness,
      bedtime: _bedtime,
      wakeTime: _wakeTime,
      smoking: _smoking,
      drinkingHabit: _drinking,
      petPreference: _pets,
    );

    await ref.read(userProfileProvider.notifier).saveProfile(
          name: _nameController.text.trim(),
          age: int.tryParse(_ageController.text.trim()) ?? currentUser.age,
          gender: currentUser.gender,
          occupation: _occupationController.text.trim(),
          bio: _bioController.text.trim(),
          avatarUrl: currentUser.avatarUrl,
          location: _locationController.text.trim(),
          preferredLocations: currentUser.preferredLocations,
          habits: updatedHabits,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile preferences saved! Compatibility scores updated.'),
          backgroundColor: AppColors.scoreHigh,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Roommate Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field('Name', _nameController),
            const SizedBox(height: 14),
            _field('Age', _ageController, isNum: true),
            const SizedBox(height: 14),
            _field('Occupation', _occupationController),
            const SizedBox(height: 14),
            _field('Location', _locationController),
            const SizedBox(height: 14),
            _field('Bio', _bioController, maxLines: 3),
            const SizedBox(height: 24),

            const Text('Monthly Budget Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            Text('\$${_budget.start.toInt()} – \$${_budget.end.toInt()}/mo', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            RangeSlider(
              values: _budget,
              min: 500,
              max: 3500,
              divisions: 30,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _budget = v),
            ),
            const SizedBox(height: 20),

            Text('Cleanliness Expectation: $_cleanliness / 5', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Slider(
              value: _cleanliness.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: AppColors.scoreHigh,
              onChanged: (v) => setState(() => _cleanliness = v.toInt()),
            ),
            const SizedBox(height: 20),

            const Text('Smoking Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            DropdownButtonFormField<SmokingPreference>(
              value: _smoking,
              items: SmokingPreference.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
              onChanged: (v) => setState(() => _smoking = v ?? _smoking),
            ),
            const SizedBox(height: 16),

            const Text('Drinking Habits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            DropdownButtonFormField<String>(
              value: _drinking,
              items: ['Never', 'Socially', 'Regularly'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => setState(() => _drinking = v ?? _drinking),
            ),
            const SizedBox(height: 16),

            const Text('Pet Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            DropdownButtonFormField<PetPreference>(
              value: _pets,
              items: PetPreference.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
              onChanged: (v) => setState(() => _pets = v ?? _pets),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {bool isNum = false, int maxLines = 1}) {
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
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          ),
        ),
      ],
    );
  }
}

