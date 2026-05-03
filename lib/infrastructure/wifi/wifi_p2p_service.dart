import 'dart:async';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import '../../domain/repository/wifi_repository.dart';
import '../../domain/model/peer_device.dart';

class WifiP2pService implements WifiRepository {
  final _p2p = FlutterP2pConnection();

  final _peersController = StreamController<List<PeerDevice>>.broadcast();
  final _connectionController = StreamController<ConnectionInfo>.broadcast();

  @override
  Stream<List<PeerDevice>> get discoveredPeersStream => _peersController.stream;

  @override
  Stream<ConnectionInfo> get connectionInfoStream =>
      _connectionController.stream;

  @override
  Future<bool> initialize() async {
    await _p2p.initialize();
    await _p2p.register();

    _p2p.streamPeers().listen((List<DiscoveredPeers> peers) {
      final mappedPeers = peers
          .map((p) => PeerDevice(
        deviceName: p.deviceName,
        deviceAddress: p.deviceAddress,
        isGroupOwner: p.isGroupOwner,
      ))
          .toList();
      _peersController.add(mappedPeers);
    });

    _p2p.streamWifiP2PInfo().listen((WifiP2PInfo info) {
      // Android devuelve InetAddress.toString() que incluye una barra inicial:
      // "/192.168.49.1" → hay que limpiarla para que Socket.connect funcione.
      final cleanIp = _sanitizeIp(info.groupOwnerAddress);

      _connectionController.add(ConnectionInfo(
        isConnected: info.isConnected,
        isGroupOwner: info.isGroupOwner,
        groupOwnerAddress: cleanIp,
      ));
    });

    return true;
  }

  /// Elimina la barra inicial que Android agrega al convertir InetAddress a String.
  String _sanitizeIp(String raw) {
    return raw.replaceAll('/', '').trim();
  }

  @override
  Future<bool> startDiscovery() async => await _p2p.discover();

  @override
  Future<bool> stopDiscovery() async => await _p2p.stopDiscovery();

  @override
  Future<bool> connectToPeer(String deviceAddress) async =>
      await _p2p.connect(deviceAddress);

  @override
  Future<bool> disconnect() async => await _p2p.removeGroup();
}