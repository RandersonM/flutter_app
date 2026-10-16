import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// gen-l10n falls back to English for a key missing from intl_pt.arb without
/// failing the build, so a Portuguese user silently sees English text. This
/// test is the only thing that catches a key added to one file but not the
/// other.
void main() {
  Set<String> keysOf(String path) {
    final arb =
        jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    return arb.keys.where((key) => !key.startsWith('@')).toSet();
  }

  test('intl_en.arb and intl_pt.arb declare the same keys', () {
    final en = keysOf('lib/l10n/intl_en.arb');
    final pt = keysOf('lib/l10n/intl_pt.arb');

    expect(
      en.difference(pt),
      isEmpty,
      reason: 'Keys in intl_en.arb missing from intl_pt.arb.',
    );
    expect(
      pt.difference(en),
      isEmpty,
      reason: 'Keys in intl_pt.arb missing from intl_en.arb.',
    );
  });
}
