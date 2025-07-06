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

BoxDecoration backgroundGradient() => BoxDecoration(
        gradient: LinearGradient(
      end: const Alignment(1, 1),
      begin: Alignment.topRight,
      colors: <Color>[
        Colors.white,
        AppColors.purple[50]!,
        AppColors.purple[100]!,
      ],
    ));
