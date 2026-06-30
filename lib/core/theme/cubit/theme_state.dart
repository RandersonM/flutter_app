import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  final bool isDarkMode;

  const ThemeState({required this.isDarkMode});

  factory ThemeState.initial() => const ThemeState(isDarkMode: false);

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  @override
  List<Object?> get props => [isDarkMode];
}
