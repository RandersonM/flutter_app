import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('BLOC ERROR: [${bloc.runtimeType}] - Error: $error');
    debugPrint('STACK TRACE:\n$stackTrace');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      // Log state *types* only — not the full toString(). Several states in
      // this app embed full model graphs (character lists, workout history,
      // user profiles), and building + printing those on every transition
      // routinely produced multi-hundred-character lines on every screen
      // navigation. Flutter's debugPrint throttles output once a burst gets
      // too large (see debugPrintThrottled), which visibly stalls the next
      // frames — i.e. this logging was itself contributing to the "tap a
      // nav button, it freezes for a bit" symptom in debug builds.
      debugPrint(
        'BLOC CHANGE: [${bloc.runtimeType}] - ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
      );
    }
  }
}
