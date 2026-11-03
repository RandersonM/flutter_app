import 'dart:async';

import 'package:opfan/core/services/connectivity/i_connectivity_service.dart';

class FakeConnectivityService implements IConnectivityService {
  final _changes = StreamController<bool>.broadcast();
  bool _online = true;

  @override
  Future<bool> isOnline() async => _online;

  @override
  Stream<bool> get onStatusChanged => _changes.stream;

  bool get hasListener => _changes.hasListener;

  void change({required bool online}) {
    _online = online;
    _changes.add(online);
  }
}
