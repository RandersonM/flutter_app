// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:opfan/core/calculator/calculator_provider.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'package:opfan/screens/calculator/widgets/calculator_content.dart';
import 'package:opfan/widgets/molecules/default_app_bar.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<CalculatorProvider>(
        create: (context) => getIt<CalculatorProvider>(),
        child: Scaffold(
          appBar: DefaultAppBar(
            title: Text(AppLocalizations.of(context)!.calculatorTitle),
          ),
          body: const CalculatorContent(),
          
        ),
      );
}
