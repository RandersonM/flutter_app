// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/calculator/bloc/calculator_cubit.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/calculator/presentation/widgets/calculator_content.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<CalculatorCubit>(
    create: (_) => getIt<CalculatorCubit>(),
    child: Scaffold(
      appBar: DefaultAppBar(
        title: Text(AppLocalizations.of(context)!.calculatorTitle),
      ),
      body: const CalculatorContent(),
    ),
  );
}
