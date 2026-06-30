import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FinanceCurrencyTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final String currencySymbol;

  const FinanceCurrencyTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.currencySymbol = 'R\$',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: TextInputType.number,
        enabled: enabled,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _CurrencyInputFormatter(currencySymbol),
        ],
        decoration: InputDecoration(
          labelText: label,
          hintText: hint ?? '0,00',
          prefixText: '$currencySymbol ',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
        ),
      ),
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  final String currencySymbol;

  _CurrencyInputFormatter(this.currencySymbol);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (text.isEmpty) {
      return newValue;
    }

    final value = int.parse(text);
    final formatted = _formatCurrency(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatCurrency(int value) {
    final reais = value ~/ 100;
    final centavos = value % 100;

    if (reais == 0) {
      return '0,${centavos.toString().padLeft(2, '0')}';
    }

    final reaisStr = reais.toString();
    final formattedReais = _addThousandSeparator(reaisStr);

    return '$formattedReais,${centavos.toString().padLeft(2, '0')}';
  }

  String _addThousandSeparator(String value) {
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(value[i]);
    }
    return buffer.toString();
  }
}
