// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:simple_app/blocs/calculator/calculator_bloc.dart';
import 'package:simple_app/shared/app_bar/default_app_bar.dart';
import 'package:simple_app/shared/bottom_navigation/bottom_navigation.dart';

import 'widgets/calculator_content.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: DefaultAppBar(
          title: Text(AppLocalizations.of(context)!.calculatorTitle),
        ),
        body: BlocProvider(
          create: (BuildContext context) => CalculatorBloc(),
          child: const CalculatorContent(),
        ),
        bottomNavigationBar:
            const BottomNavigation(BottomNavigationPages.calculator),
      );
}
