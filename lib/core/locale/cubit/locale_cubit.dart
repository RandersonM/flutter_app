import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/locale/cubit/locale_state.dart';
import 'package:opfan/core/services/locale_service.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(LocaleState(locale: LocaleService.locale));

  Future<void> setLocale(Locale locale) async {
    await LocaleService.persistLocale(locale);
    emit(LocaleState(locale: locale));
  }
}
