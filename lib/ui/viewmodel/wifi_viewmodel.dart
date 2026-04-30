import 'package:flutter/material.dart';
import '../../domain/model/peer_device.dart';
import '../../domain/repository/wifi_repository.dart'; // Para ConnectionInfo
import '../../application/wifi/wifi_controller.dart';
import 'chat_viewmodel.dart';

class WifiViewModel extends ChangeNotifier {
  final WifiController _wifiController;
  final ChatViewModel _chatViewModel;

  List<PeerDevice> availablePeers = [];
  ConnectionInfo? currentConnection;
  bool isSearching = false;

  // Ahora recibe su propio controlador y el ViewModel del chat
  WifiViewModel(this._wifiController, this._chatViewModel) {
    _initStreams();
  }

  void _initStreams() {
    // Escuchar dispositivos descubiertos desde el controlador
    _wifiController.discoveredPeers.listen((peers) {
      availablePeers = peers;
      notifyListeners();
    });

    // Escuchar el resultado del Handshake desde el controlador
    _wifiController.connectionStatus.listen((info) {
      currentConnection = info;
      notifyListeners();

      // Cuando se conecta el Wi-Fi Direct, arranca la red TCP del chat
      if (info.isConnected) {
        _chatViewModel.setupConnection(
            info.isGroupOwner,
            info.groupOwnerAddress
        );
      }
    });
  }

  Future<void> initializeAndDiscover() async {
    await _wifiController.initializeNetwork();
    isSearching = await _wifiController.scanForDevices();
    notifyListeners();
  }

  Future<void> connect(PeerDevice device) async {
    await _wifiController.connectTo(device);
  }

  Future<void> disconnect() async {
    await _wifiController.disconnect();
    currentConnection = null;
    notifyListeners();
  }
}