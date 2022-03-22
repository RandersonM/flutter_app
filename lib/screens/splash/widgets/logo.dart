// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String _logoPath = 'assets/logo/splash_logo.png';

    return const Image(
      image: AssetImage(_logoPath),
    );
  }
}
