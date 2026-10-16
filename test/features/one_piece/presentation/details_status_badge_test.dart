import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/features/one_piece/presentation/widgets/details/fields/details_status_badge.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/app_semantic_colors.dart';
import 'package:opfan/shared/utils/theme.dart';

Future<void> _pumpBadge(
  WidgetTester tester, {
  required String status,
  required ThemeData theme,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: theme,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: DetailsStatusBadge(status: status)),
    ),
  );
}

Color? _badgeColor(WidgetTester tester) {
  final container = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(DetailsStatusBadge),
          matching: find.byType(Container),
        )
        .first,
  );
  return (container.decoration! as BoxDecoration).color;
}

Color? _labelColor(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style?.color;

void main() {
  for (final theme in [getLightTheme(), getDarkTheme()]) {
    group('DetailsStatusBadge (${theme.brightness.name})', () {
      testWidgets('alive uses the success role', (tester) async {
        await _pumpBadge(tester, status: 'Living', theme: theme);

        expect(_badgeColor(tester), theme.semanticColors.success);
        expect(_labelColor(tester, 'Alive'), theme.semanticColors.onSuccess);
      });

      testWidgets('deceased uses the error role', (tester) async {
        await _pumpBadge(tester, status: 'Deceased', theme: theme);

        expect(_badgeColor(tester), theme.colorScheme.error);
        expect(_labelColor(tester, 'Dead'), theme.colorScheme.onError);
      });

      testWidgets('captured uses the warning role', (tester) async {
        await _pumpBadge(tester, status: 'Captured', theme: theme);

        expect(_badgeColor(tester), theme.semanticColors.warning);
        expect(_labelColor(tester, 'Captured'), theme.semanticColors.onWarning);
      });

      testWidgets('unknown contrasts with the surface', (tester) async {
        await _pumpBadge(tester, status: 'Who knows', theme: theme);

        expect(
          _badgeColor(tester),
          theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        );
        expect(_labelColor(tester, 'Unknown'), theme.colorScheme.surface);
      });
    });
  }
}
