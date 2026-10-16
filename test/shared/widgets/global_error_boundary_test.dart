import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/l10n/app_localizations_en.dart';
import 'package:opfan/shared/widgets/global_error_boundary.dart';

/// Throws on its first build only, like a transient render failure.
class _FlakyChild extends StatefulWidget {
  const _FlakyChild();

  @override
  State<_FlakyChild> createState() => _FlakyChildState();
}

bool _failNextBuild = true;

class _FlakyChildState extends State<_FlakyChild> {
  @override
  Widget build(BuildContext context) {
    if (_failNextBuild) {
      _failNextBuild = false;
      throw StateError('render failed');
    }
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Text('app content'),
    );
  }
}

void main() {
  final l10n = AppLocalizationsEn();

  group('GlobalErrorBoundary behaviour', () {
    testWidgets('go home clears the error and hands navigation to the app', (
      tester,
    ) async {
      var wentHome = 0;
      _failNextBuild = true;

      await tester.pumpWidget(
        GlobalErrorBoundary(
          onGoHome: () => wentHome++,
          child: const _FlakyChild(),
        ),
      );
      expect(tester.takeException(), isA<StateError>());
      await tester.pumpAndSettle();
      expect(find.text(l10n.errorBoundaryTitle), findsOneWidget);

      await tester.tap(find.text(l10n.goHomeAction));
      await tester.pumpAndSettle();

      expect(wentHome, 1);
      expect(find.text('app content'), findsOneWidget);
    });
  });
}
