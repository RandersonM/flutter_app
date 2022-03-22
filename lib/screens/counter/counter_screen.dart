// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:simple_app/core/counter/counter_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simple_app/shared/app_bar/default_app_bar.dart';

import '../../shared/bottom_navigation/bottom_navigation.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({Key? key}) : super(key: key);

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CounterProvider>(
      create: (BuildContext context) => CounterProvider(),
      child: Consumer<CounterProvider>(
        builder: (BuildContext context, CounterProvider provider, _) =>
            Scaffold(
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
                Text(
                  '${provider.counter}',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
          ),
          bottomNavigationBar:
              const BottomNavigation(BottomNavigationPages.counter),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              provider.increment();
            },
            tooltip: AppLocalizations.of(context)!.home,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
