// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/screens/splash/widgets/logo.dart';
import 'package:opfan/utils/app_routes.dart';
import 'package:opfan/utils/decorations/gradient.dart';

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
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (_) => false,
        );
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
