// Developed by Randerson Mayllon
// Copyright © 2022.
import 'package:flutter/material.dart';

import '../theme.dart';

BoxDecoration purpleGradient() => BoxDecoration(
        gradient: LinearGradient(
      begin: const Alignment(-0.2, 1),
      end: Alignment.topRight,
      colors: <Color>[
        AppColors.gradientPurple[200]!,
        AppColors.gradientPurple[500]!,
        AppColors.gradientPurple[800]!,
      ],
    ));
