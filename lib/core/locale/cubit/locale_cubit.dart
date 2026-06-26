import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/locale/cubit/locale_state.dart';
import 'package:opfan/core/services/index.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(LocaleState(locale: GetIt.I.get<ILocaleService>().locale));

  Future<void> setLocale(Locale locale) async {
    await GetIt.I.get<ILocaleService>().persistLocale(locale);
    emit(LocaleState(locale: locale));
  }
}
