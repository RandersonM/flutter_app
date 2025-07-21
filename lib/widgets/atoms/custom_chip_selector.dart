import 'package:flutter/material.dart';

class CustomChipSelector extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selectedOptions;
  final void Function(String) onOptionSelected;
  final void Function(String) onOptionDeselected;
  final int? maxSelections;

  const CustomChipSelector({
    Key? key,
    required this.label,
    required this.options,
    required this.selectedOptions,
    required this.onOptionSelected,
    required this.onOptionDeselected,
    this.maxSelections,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selectedOptions.contains(option);
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    if (maxSelections == null || selectedOptions.length < maxSelections!) {
                      onOptionSelected(option);
                    }
                  } else {
                    onOptionDeselected(option);
                  }
                },
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                checkmarkColor: Theme.of(context).primaryColor,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
} 