// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simple_app/shared/app_bar/default_app_bar.dart';
import 'package:simple_app/shared/bottom_navigation/bottom_navigation.dart';
import 'package:simple_app/shared/transitions/material_page_route_with_slide_right_transition.dart';
import 'package:simple_app/ui/screens/movies/movie_search.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({Key? key}) : super(key: key);

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: Text(AppLocalizations.of(context)!.counterTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.howManyPushPhrase,
            ),
            ElevatedButton(
                onPressed: () => Navigator.push(
                      context,
                      MaterialPageRouteWithSlideRightTransition(
                          builder: (_) => const MovieSearch()),
                    ),
                child: const Text('Movie Section'))
          ],
        ),
      ),
      bottomNavigationBar:
          const BottomNavigation(BottomNavigationPages.counter),
    );
  }
}
