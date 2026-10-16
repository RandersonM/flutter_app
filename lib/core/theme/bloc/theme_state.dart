import 'package:equatable/equatable.dart';

class ThemeState extends Equatable {
  final bool isDarkMode;

  const ThemeState({required this.isDarkMode});

  factory ThemeState.initial() => const ThemeState(isDarkMode: false);

  @override
  List<Object?> get props => [isDarkMode];
}
