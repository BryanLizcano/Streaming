import 'dart:async';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import '../../domain/repository/wifi_repository.dart';
import '../../domain/model/peer_device.dart';

class WifiP2pService implements WifiRepository {
  final _p2p = FlutterP2pConnection();

  // Controladores para exponer los datos a la capa de presentación
  final _peersController = StreamController<List<PeerDevice>>.broadcast();
  final _connectionController = StreamController<ConnectionInfo>.broadcast();

  @override
  Stream<List<PeerDevice>> get discoveredPeersStream => _peersController.stream;

  @override
  Stream<ConnectionInfo> get connectionInfoStream => _connectionController.stream;

  @override
  Future<bool> initialize() async {
    await _p2p.initialize();
    await _p2p.register();

    // Escuchar cambios en los dispositivos descubiertos
    _p2p.streamPeers().listen((List<DiscoveredPeers> peers) {
      final mappedPeers = peers.map((p) => PeerDevice(
        deviceName: p.deviceName,
        deviceAddress: p.deviceAddress,
        isGroupOwner: p.isGroupOwner,
      )).toList();
      _peersController.add(mappedPeers);
    });

    // Escuchar el estado de la conexión (El Handshake)
    _p2p.streamWifiP2PInfo().listen((WifiP2PInfo info) {
      _connectionController.add(ConnectionInfo(
        isConnected: info.isConnected,
        isGroupOwner: info.isGroupOwner,
        groupOwnerAddress: info.groupOwnerAddress,
      ));
    });

    return true;
  }

  @override
  Future<bool> startDiscovery() async {
    return await _p2p.discover();
  }

  @override
  Future<bool> stopDiscovery() async {
    return await _p2p.stopDiscovery();
  }

  @override
  Future<bool> connectToPeer(String deviceAddress) async {
    // Al conectar, el sistema operativo negocia quién será el GO (Group Owner)
    return await _p2p.connect(deviceAddress);
  }

  @override
  Future<bool> disconnect() async {
    return await _p2p.removeGroup();
  }
}