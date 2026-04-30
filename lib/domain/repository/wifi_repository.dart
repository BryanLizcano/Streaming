import '../model/peer_device.dart';

abstract class WifiRepository {
  Future<bool> initialize();
  Future<bool> startDiscovery();
  Future<bool> stopDiscovery();
  Future<bool> connectToPeer(String deviceAddress);
  Future<bool> disconnect();

  Stream<List<PeerDevice>> get discoveredPeersStream;
  Stream<ConnectionInfo> get connectionInfoStream;
}

// Modelo auxiliar para la conexión
class ConnectionInfo {
  final bool isConnected;
  final bool isGroupOwner;
  final String groupOwnerAddress;

  ConnectionInfo({
    required this.isConnected,
    required this.isGroupOwner,
    required this.groupOwnerAddress,
  });
}