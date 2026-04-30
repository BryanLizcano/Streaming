abstract class NetworkRepository {
  Future<void> startServer(int port);
  Future<void> connectToServer(String ip, int port);
  void sendMessage(String message);
  Stream<String> get messageStream;
}