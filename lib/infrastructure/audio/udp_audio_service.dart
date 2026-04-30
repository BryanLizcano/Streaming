import 'dart:io';
import 'dart:async';

class UdpAudioService {
  RawDatagramSocket? _udpSocket;
  final int audioPort = 50000;

  // Se encarga de escuchar los bytes crudos y mandarlos al reproductor
  final _audioStreamController = StreamController<List<int>>.broadcast();
  Stream<List<int>> get audioStream => _audioStreamController.stream;

  Future<void> initUdpReceiver() async {
    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, audioPort);
    _udpSocket!.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram? datagram = _udpSocket!.receive();
        if (datagram != null) {
          _audioStreamController.add(datagram.data);
        }
      }
    });
  }

  void sendAudioBuffer(List<int> pcmData, String targetIp) {
    if (_udpSocket != null) {
      _udpSocket!.send(pcmData, InternetAddress(targetIp), audioPort);
    }
  }
}