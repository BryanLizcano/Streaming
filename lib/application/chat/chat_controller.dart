import '../../domain/repository/network_repository.dart';

class ChatController {
  final NetworkRepository _networkRepository;

  ChatController(this._networkRepository);

  Stream<String> get incomingMessages => _networkRepository.messageStream;

  Future<void> establishChatRoom({required bool isGroupOwner, required String ipAddress}) async {
    try {
      if (isGroupOwner) {
        // Puerto estándar para nuestro laboratorio TCP
        await _networkRepository.startServer(8888);
      } else {
        await _networkRepository.connectToServer(ipAddress, 8888);
      }
    } catch (e) {
      throw Exception("Error al establecer la sala de chat: $e");
    }
  }

  void sendTextMessage(String message) {
    if (message.trim().isEmpty) return; // Validaciones de negocio
    _networkRepository.sendMessage(message);
  }
}