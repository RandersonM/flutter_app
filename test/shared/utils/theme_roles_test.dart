import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/shared/utils/theme.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  final themes = {'light': getLightTheme(), 'dark': getDarkTheme()};

  for (final MapEntry(key: name, value: theme) in themes.entries) {
    final scheme = theme.colorScheme;

    group('$name theme colour roles', () {
      test('muted text stays readable on surfaces', () {
        for (final surface in [scheme.surface, scheme.surfaceContainer]) {
          expect(_contrast(scheme.onSurfaceVariant, surface), greaterThan(4.5));
        }
      });

      test('muted text is distinct from body text', () {
        expect(scheme.onSurfaceVariant, isNot(scheme.onSurface));
      });

      test('error text stays readable on surfaces', () {
        for (final surface in [scheme.surface, scheme.surfaceContainer]) {
          expect(_contrast(scheme.error, surface), greaterThan(3));
        }
      });

      test('error container text is readable', () {
        expect(
          _contrast(scheme.onErrorContainer, scheme.errorContainer),
          greaterThan(4.5),
        );
      });

      test('outlines are visible against surfaces', () {
        for (final surface in [scheme.surface, scheme.surfaceContainer]) {
          expect(scheme.outlineVariant, isNot(surface));
          expect(_contrast(scheme.outline, surface), greaterThan(1.8));
        }
      });

      test('container tones step away from the surface', () {
        expect(
          scheme.surfaceContainerHighest,
          isNot(scheme.surfaceContainerLowest),
        );
      });
    });
  }
}
