import 'dart:ui' show Locale;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/locale/bloc/locale_state.dart';
import 'package:opfan/core/services/index.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit(this._localeService)
    : super(LocaleState(locale: _localeService.locale));

  final ILocaleService _localeService;

  Future<void> setLocale(Locale locale) async {
    await _localeService.persistLocale(locale);
    emit(LocaleState(locale: locale));
  }
}
