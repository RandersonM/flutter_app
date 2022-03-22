// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  const CalculatorButton(
      {Key? key,
      required this.color,
      required this.textColor,
      required this.buttonText,
      required this.buttontapped})
      : super(key: key);

  final Color color;
  final Color textColor;
  final String buttonText;
  final Function() buttontapped;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: buttontapped,
      child: Padding(
        padding: const EdgeInsets.all(0.2),
        child: ClipRRect(
          // borderRadius: BorderRadius.circular(25),
          child: Container(
            color: color,
            child: Center(
              child: Text(
                buttonText,
                style: Theme.of(context).textTheme.headline6!.merge(
                    TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
