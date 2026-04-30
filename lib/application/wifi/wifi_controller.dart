import '../../domain/repository/wifi_repository.dart';
import '../../domain/model/peer_device.dart';

class WifiController {
  final WifiRepository _wifiRepository;

  WifiController(this._wifiRepository);

  Stream<List<PeerDevice>> get discoveredPeers => _wifiRepository.discoveredPeersStream;
  Stream<ConnectionInfo> get connectionStatus => _wifiRepository.connectionInfoStream;

  Future<bool> initializeNetwork() async {
    return await _wifiRepository.initialize();
  }

  Future<bool> scanForDevices() async {
    return await _wifiRepository.startDiscovery();
  }

  Future<bool> connectTo(PeerDevice device) async {
    if (device.deviceAddress.isEmpty) return false;
    return await _wifiRepository.connectToPeer(device.deviceAddress);
  }

  Future<bool> disconnect() async {
    return await _wifiRepository.disconnect();
  }
}