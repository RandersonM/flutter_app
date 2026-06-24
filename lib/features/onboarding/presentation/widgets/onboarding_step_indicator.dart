// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:flutter/material.dart';

class OnboardingStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: isActive ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(4.0),
          ),
        );
      }),
    );
  }
}
