import 'package:equatable/equatable.dart';
import 'dart:ui' show Locale;

class LocaleState extends Equatable {
  final Locale? locale;

  const LocaleState({this.locale});

  @override
  List<Object?> get props => [locale];
}
