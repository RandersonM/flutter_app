// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:simple_app/screens/counter/counter_screen.dart';
import 'package:simple_app/screens/splash/widgets/logo.dart';
import 'package:simple_app/shared/decorations/gradient.dart';
import 'package:simple_app/shared/transitions/material_page_route_with_slide_right_transition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future<void>.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRouteWithSlideRightTransition(
                builder: (_) => const CounterScreen()),
            (_) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: purpleGradient(),
        child: const Center(
          child: FractionallySizedBox(
            widthFactor: .5,
            child: SplashLogo(),
          ),
        ),
      ),
    );
  }
}
