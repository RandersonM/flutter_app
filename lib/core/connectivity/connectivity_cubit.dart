import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'connectivity_state.dart';

/// Global singleton Cubit that tracks network connectivity.
///
/// Uses a 1500ms debounce to avoid flicker when the device rapidly switches
/// between online/offline states (e.g., switching Wi-Fi networks).
///
/// Register via GetIt:
/// ```dart
/// getIt.registerSingleton<ConnectivityCubit>(ConnectivityCubit());
/// ```
class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit() : super(const ConnectivityOnline()) {
    _init();
  }

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _debounce;

  static const _debounceDuration = Duration(milliseconds: 1500);

  void _init() {
    // Subscribe to connectivity changes
    _subscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    // Check initial state without debounce
    Connectivity().checkConnectivity().then((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (!isOnline) {
        emit(const ConnectivityOffline());
      }
    });
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      debugPrint('ConnectivityCubit: ${isOnline ? "online" : "offline"}');
      if (isOnline) {
        emit(const ConnectivityOnline());
      } else {
        emit(const ConnectivityOffline());
      }
    });
  }

  /// Synchronous check — safe to call outside of async context.
  bool get isOnline => state is ConnectivityOnline;

  @override
  Future<void> close() {
    _debounce?.cancel();
    _subscription?.cancel();
    return super.close();
  }
}
