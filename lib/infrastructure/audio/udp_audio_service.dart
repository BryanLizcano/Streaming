import 'dart:io';
import 'dart:async';

class UdpAudioService {
  RawDatagramSocket? _socket;
  final int port = 50002;

  final _audioStreamController = StreamController<List<int>>.broadcast();
  Stream<List<int>> get audioStream => _audioStreamController.stream;

  Future<void> init() async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    _socket!.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final dg = _socket!.receive();
        if (dg != null) _audioStreamController.add(dg.data);
      }
    });
  }

  void send(List<int> data, String targetIp) {
    final cleanIp = targetIp.replaceAll('/', '');
    _socket?.send(data, InternetAddress(cleanIp), port);
  }

  // 🟢 MÉTODO AGREGADO
  void dispose() {
    _socket?.close();
    _audioStreamController.close();
  }
}