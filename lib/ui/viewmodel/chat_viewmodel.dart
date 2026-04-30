import 'package:flutter/material.dart';
import 'package:streaming/application/chat/chat_controller.dart';
import '../../infrastructure/network/tcp_socket_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatController _chatController;
  final TcpSocketService _tcpService = TcpSocketService();
  List<String> messages = [];
  bool _isGroupOwner = false;

  ChatViewModel(this._chatController) {
    _tcpService.messageStream.listen((msg) {
      messages.add(msg);
      notifyListeners();
    });
  }

  Future<void> setupConnection(bool isGroupOwner, String goIpAddress) async {
    _isGroupOwner = isGroupOwner;
    if (isGroupOwner) {
      await _tcpService.startServer(8888);
    } else {
      await _tcpService.connectToServer(goIpAddress, 8888);
    }
  }

  void sendText(String text) {
    _tcpService.sendMessage(text);
    if (!_isGroupOwner) { // Simulando adición local para cliente
      messages.add("Yo: $text");
      notifyListeners();
    }
  }
}