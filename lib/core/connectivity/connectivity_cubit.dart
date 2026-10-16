import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/services/connectivity/i_connectivity_service.dart';

import 'connectivity_state.dart';

/// Global singleton Cubit that tracks network connectivity for the UI.
///
/// Uses a 1500ms debounce to avoid flicker when the device rapidly switches
/// between online/offline states (e.g., switching Wi-Fi networks).
class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit({required this._connectivityService})
    : super(const ConnectivityOnline()) {
    _init();
  }

  final IConnectivityService _connectivityService;
  StreamSubscription<bool>? _subscription;
  Timer? _debounce;

  static const _debounceDuration = Duration(milliseconds: 1500);

  void _init() {
    _subscription = _connectivityService.onStatusChanged.listen(
      _onConnectivityChanged,
    );

    // The first check skips the debounce so an offline start shows at once.
    _connectivityService.isOnline().then((isOnline) {
      if (!isOnline && !isClosed) emit(const ConnectivityOffline());
    });
  }

  void _onConnectivityChanged(bool isOnline) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      debugPrint('ConnectivityCubit: ${isOnline ? "online" : "offline"}');
      emit(isOnline ? const ConnectivityOnline() : const ConnectivityOffline());
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
