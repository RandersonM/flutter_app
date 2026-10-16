import 'package:connectivity_plus/connectivity_plus.dart';

import 'i_connectivity_service.dart';

class ConnectivityService implements IConnectivityService {
  final _connectivity = Connectivity();

  @override
  Future<bool> isOnline() async =>
      _hasNetwork(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get onStatusChanged =>
      _connectivity.onConnectivityChanged.map(_hasNetwork);

  bool _hasNetwork(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}
