import 'dart:async';
import 'dart:io';
import 'dart:convert';
import '../../domain/repository/network_repository.dart';

class TcpSocketService implements NetworkRepository {
  ServerSocket? _serverSocket;
  Socket? _clientSocket;
  final List<Socket> _connectedClients = [];

  String? _peerIp;
  String? get peerIp => _peerIp;

  final _messageController = StreamController<String>.broadcast();

  @override
  Stream<String> get messageStream => _messageController.stream;

  // ─── Group Owner: inicia el servidor ──────────────────────────────────────

  @override
  Future<void> startServer(int port) async {
    if (_serverSocket != null) return;
    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);

    _serverSocket!.listen((Socket client) {
      _peerIp = client.remoteAddress.address;
      _connectedClients.add(client);

      // Confirmar a la UI que el par llegó
      _messageController.add('__SYSTEM__ ¡Par conectado! Ahora pueden chatear.');

      client.listen(
            (List<int> data) {
          final message = utf8.decode(data);
          _messageController.add('Par: $message');
          _broadcastToClients(message, sender: client);
        },
        onDone: () => _connectedClients.remove(client),
        onError: (_) => _connectedClients.remove(client),
      );
    });
  }

  // ─── Cliente: conecta al GO con reintentos ─────────────────────────────────

  @override
  Future<void> connectToServer(String ip, int port) async {
    if (_clientSocket != null) return;
    _peerIp = ip;

    final cleanIp = ip.replaceAll('/', '');
    _clientSocket = await Socket.connect(cleanIp, port);

    Exception? lastError;
    for (int attempt = 0; attempt < 5; attempt++) {
      try {
        _clientSocket = await Socket.connect(
          ip,
          port,
          timeout: const Duration(seconds: 4),
        );

        _clientSocket!.listen(
              (List<int> data) {
            final message = utf8.decode(data);
            _messageController.add('Par: $message');
          },
          onError: (_) => _clientSocket = null,
          onDone: () => _clientSocket = null,
        );

        // Conexión exitosa: confirmar en la UI
        _messageController.add('__SYSTEM__ ¡Conectado! Ahora pueden chatear.');
        return;
      } catch (e) {
        lastError = Exception('Intento ${attempt + 1} fallido: $e');
        if (attempt < 4) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }

    // Si llegamos aquí, todos los reintentos fallaron → propagar el error
    throw lastError!;
  }

  // ─── Enviar mensaje ────────────────────────────────────────────────────────

  @override
  void sendMessage(String message) {
    final bytes = utf8.encode(message);

    if (_clientSocket != null) {
      _clientSocket!.add(bytes);
    } else {
      _broadcastToClients(message);
    }

    _messageController.add('Yo: $message');
  }

  void _broadcastToClients(String message, {Socket? sender}) {
    final bytes = utf8.encode(message);
    for (final client in _connectedClients) {
      if (client != sender) client.add(bytes);
    }
  }

  Future<void> dispose() async {
    await _serverSocket?.close();
    await _clientSocket?.close();
    await _messageController.close();
  }
}