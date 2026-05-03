import 'package:flutter/material.dart';
import '../../application/chat/chat_controller.dart';
import '../../infrastructure/network/tcp_socket_service.dart';

enum ChatConnectionStatus { idle, connecting, waitingForPeer, connected, failed }

class ChatViewModel extends ChangeNotifier {
  final ChatController _chatController;
  final TcpSocketService _tcpService = TcpSocketService();
  final List<String> messages = [];

  ChatConnectionStatus _status = ChatConnectionStatus.idle;
  ChatConnectionStatus get status => _status;
  bool get isConnected => _status == ChatConnectionStatus.connected;

  /// IP real del par (GO o cliente); se usa para dirigir el audio UDP.
  String? get peerIp => _tcpService.peerIp;

  ChatViewModel(this._chatController) {
    _tcpService.messageStream.listen((msg) {
      if (msg.startsWith('__SYSTEM__')) {
        // Mensaje de sistema → marcar como conectado + mostrarlo en la UI
        _status = ChatConnectionStatus.connected;
        messages.add('🔗 ${msg.replaceFirst('__SYSTEM__ ', '')}');
      } else {
        messages.add(msg);
      }
      notifyListeners();
    });
  }

  Future<void> setupConnection(bool isGroupOwner, String goIpAddress) async {
    // Evitar llamadas duplicadas
    if (_status != ChatConnectionStatus.idle &&
        _status != ChatConnectionStatus.failed) return;

    try {
      if (isGroupOwner) {
        _status = ChatConnectionStatus.connecting;
        notifyListeners();

        await _tcpService.startServer(8888);

        // El servidor ya está escuchando → ahora esperamos que el cliente conecte.
        // El estado pasa a "connected" cuando llega el mensaje __SYSTEM__ del listener.
        _status = ChatConnectionStatus.waitingForPeer;
        notifyListeners();
      } else {
        _status = ChatConnectionStatus.connecting;
        notifyListeners();

        // connectToServer lanza excepción si todos los reintentos fallan
        await _tcpService.connectToServer(goIpAddress, 8888);

        // El estado pasa a "connected" cuando llega el mensaje __SYSTEM__
        // (ya fue emitido dentro de connectToServer al tener éxito)
      }
    } catch (_) {
      _status = ChatConnectionStatus.failed;
      notifyListeners();
    }
  }

  void sendText(String text) {
    if (text.trim().isEmpty || !isConnected) return;
    _tcpService.sendMessage(text);
  }
}