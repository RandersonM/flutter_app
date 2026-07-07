// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  const CalculatorButton({
    super.key,
    required this.color,
    required this.textColor,
    required this.buttonText,
    required this.buttontapped,
  });

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
          child: Container(
            color: color,
            child: Center(
              child: Text(
                buttonText,
                style: Theme.of(context).textTheme.headlineSmall!.merge(
                  TextStyle(fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
