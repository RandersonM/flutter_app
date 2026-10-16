import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:opfan/core/ai/prompts/prompt_locale.dart';
import 'package:opfan/core/services/config/i_locale_service.dart';
import 'package:opfan/core/services/config/locale_service.dart';

class _FixedLocaleService implements ILocaleService {
  _FixedLocaleService(this.languageCode);

  @override
  final String languageCode;
  @override
  Locale? get locale => Locale(languageCode);
  @override
  Future<void> loadLocale() async {}
  @override
  Future<void> persistLocale(Locale locale) async {}
}

void main() {
  late Directory hiveDir;

  setUp(() {
    hiveDir = Directory.systemTemp.createTempSync('locale_service_test');
    Hive.init(hiveDir.path);
  });

  tearDown(() async {
    await Hive.close();
    hiveDir.deleteSync(recursive: true);
  });

  group('LocaleService behaviour', () {
    test('follows the device language until the user picks one', () {
      expect(
        LocaleService().languageCode,
        ui.PlatformDispatcher.instance.locale.languageCode,
      );
    });

    test('uses the language the user picked', () async {
      final service = LocaleService();
      await service.persistLocale(const Locale('pt'));

      expect(service.languageCode, 'pt');
    });
  });

  group('PromptLocale behaviour', () {
    test('builds Portuguese prompts only for pt', () {
      expect(PromptLocale.isPortuguese(_FixedLocaleService('pt')), isTrue);
      expect(PromptLocale.isPortuguese(_FixedLocaleService('en')), isFalse);
    });
  });
}
