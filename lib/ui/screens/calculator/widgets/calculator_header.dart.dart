// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simple_app/blocs/calculator/calculator_bloc.dart';

import 'package:simple_app/shared/constants.dart';

class CalculatorHeader extends StatefulWidget {
  const CalculatorHeader({Key? key}) : super(key: key);

  @override
  State<CalculatorHeader> createState() => _CalculatorHeaderState();
}

class _CalculatorHeaderState extends State<CalculatorHeader> {
  String _result = '';
  String _input = '';

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalculatorBloc, CalculatorState>(
      listener: (BuildContext context, CalculatorState state) {
        if (state is CalculatorFailed) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.error),
          ));
        }
      },
      child: BlocBuilder<CalculatorBloc, CalculatorState>(
        bloc: BlocProvider.of<CalculatorBloc>(context),
        builder: (BuildContext context, CalculatorState state) {
          if (state is CalculatorSuccess) {
            _result = state.result;
          }
          if (state is CalculatorInitial) {
            _input = '';
            _result = '';
          }
          if (state is CalculatorInputed) {
            _input = state.input;
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(Constants.margin),
                child: Text(
                  _input,
                  style: Theme.of(context).textTheme.subtitle1!,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: Constants.margin,
                    right: Constants.margin,
                    bottom: Constants.margin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(AppLocalizations.of(context)!.result,
                        style: Theme.of(context).textTheme.headline6!.merge(
                            const TextStyle(fontWeight: FontWeight.bold))),
                    Text(
                      _result,
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .merge(const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
