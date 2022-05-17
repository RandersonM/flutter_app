// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:simple_app/shared/decorations/gradient.dart';
import 'package:simple_app/shared/transitions/material_page_route_with_slide_right_transition.dart';
import 'package:simple_app/ui/screens/movies/movie_search_screen.dart';

import 'widgets/logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future<void>.delayed(
        const Duration(seconds: 3),
        () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRouteWithSlideRightTransition(
                builder: (_) => const MovieSearchSreen()),
            (_) => false));
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
