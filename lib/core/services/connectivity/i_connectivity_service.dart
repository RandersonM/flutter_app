abstract class IConnectivityService {
  /// Whether any network interface is currently up.
  Future<bool> isOnline();

  /// Emits `true`/`false` each time the network interfaces change.
  Stream<bool> get onStatusChanged;
}
