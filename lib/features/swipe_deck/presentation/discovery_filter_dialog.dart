import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class FilterCriteria {
  RangeValues budgetRange;
  int minCleanliness;
  bool strictNonSmokerOnly;
  bool petFriendlyOnly;
  double minCompatibilityScore;

  FilterCriteria({
    this.budgetRange = const RangeValues(800, 2500),
    this.minCleanliness = 1,
    this.strictNonSmokerOnly = false,
    this.petFriendlyOnly = false,
    this.minCompatibilityScore = 50.0,
  });
}

class DiscoveryFilterDialog extends StatefulWidget {
  final FilterCriteria initialCriteria;
  final ValueChanged<FilterCriteria> onApply;

  const DiscoveryFilterDialog({
    super.key,
    required this.initialCriteria,
    required this.onApply,
  });

  @override
  State<DiscoveryFilterDialog> createState() => _DiscoveryFilterDialogState();
}

class _DiscoveryFilterDialogState extends State<DiscoveryFilterDialog> {
  late RangeValues _budget;
  late int _cleanliness;
  late bool _nonSmoker;
  late bool _petFriendly;
  late double _minScore;

  @override
  void initState() {
    super.initState();
    _budget = widget.initialCriteria.budgetRange;
    _cleanliness = widget.initialCriteria.minCleanliness;
    _nonSmoker = widget.initialCriteria.strictNonSmokerOnly;
    _petFriendly = widget.initialCriteria.petFriendlyOnly;
    _minScore = widget.initialCriteria.minCompatibilityScore;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Flatmates',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _budget = const RangeValues(800, 2500);
                    _cleanliness = 1;
                    _nonSmoker = false;
                    _petFriendly = false;
                    _minScore = 50.0;
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Budget: \$${_budget.start.toInt()} – \$${_budget.end.toInt()}/mo',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          RangeSlider(
            values: _budget,
            min: 500,
            max: 3500,
            divisions: 30,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _budget = val),
          ),
          const SizedBox(height: 12),
          Text(
            'Minimum Cleanliness: $_cleanliness / 5',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Slider(
            value: _cleanliness.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: AppColors.scoreHigh,
            onChanged: (val) => setState(() => _cleanliness = val.toInt()),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Strict Non-Smokers Only', style: TextStyle(fontSize: 14)),
            value: _nonSmoker,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _nonSmoker = val),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Pet-Friendly Flatmates Only', style: TextStyle(fontSize: 14)),
            value: _petFriendly,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _petFriendly = val),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onApply(FilterCriteria(
                  budgetRange: _budget,
                  minCleanliness: _cleanliness,
                  strictNonSmokerOnly: _nonSmoker,
                  petFriendlyOnly: _petFriendly,
                  minCompatibilityScore: _minScore,
                ));
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    ),
  );
  }
}

