import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemToString;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemToString,
    required this.onChanged,
    this.validator,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemToString(item),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: enabled ? onChanged : null,
        validator: validator,
        selectedItemBuilder: (BuildContext context) {
          return items.map<Widget>((T item) {
            return Text(
              itemToString(item),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            );
          }).toList();
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: enabled ? Colors.grey[50] : Colors.grey[200],
        ),
      ),
    );
  }
} 