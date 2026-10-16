import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('BLOC ERROR: [${bloc.runtimeType}] - Error: $error');
    debugPrint('STACK TRACE:\n$stackTrace');
  }
}
