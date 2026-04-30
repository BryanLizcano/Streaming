import 'dart:async';
import 'dart:io';
import 'dart:convert';
import '../../domain/repository/network_repository.dart';

class TcpSocketService implements NetworkRepository {
  ServerSocket? _serverSocket;
  Socket? _clientSocket;
  final List<Socket> _connectedClients = [];

  final _messageController = StreamController<String>.broadcast();
  @override
  Stream<String> get messageStream => _messageController.stream;

  // Lógica del Group Owner (GO)
  @override
  Future<void> startServer(int port) async {
    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    print("Servidor P2P iniciado en puerto $port");

    _serverSocket!.listen((Socket client) {
      _connectedClients.add(client);
      client.listen(
            (List<int> data) {
          final message = utf8.decode(data);
          _messageController.add(message); // Mostrar en UI
          _broadcastToClients(message, sender: client); // Retransmitir a otros
        },
        onDone: () => _connectedClients.remove(client),
      );
    });
  }

  // Lógica del Cliente P2P
  @override
  Future<void> connectToServer(String ip, int port) async {
    _clientSocket = await Socket.connect(ip, port);
    _clientSocket!.listen((List<int> data) {
      final message = utf8.decode(data);
      _messageController.add(message);
    });
  }

  @override
  void sendMessage(String message) {
    final bytes = utf8.encode(message);
    if (_clientSocket != null) {
      _clientSocket!.add(bytes); // Soy cliente, envío al GO
    } else {
      _messageController.add("Yo: $message");
      _broadcastToClients(message); // Soy GO, distribuyo a la sala
    }
  }

  void _broadcastToClients(String message, {Socket? sender}) {
    final bytes = utf8.encode(message);
    for (var client in _connectedClients) {
      if (client != sender) {
        client.add(bytes);
      }
    }
  }
}