// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:flutter/material.dart';

class OnboardingBodyForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Widget child;

  const OnboardingBodyForm({
    super.key,
    required this.formKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Form(key: formKey, child: child);
  }
}
