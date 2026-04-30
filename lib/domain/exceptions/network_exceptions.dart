class PeerConnectionException implements Exception {
  final String message;
  PeerConnectionException([this.message = "Error al conectar con el par (Peer)."]);
  @override
  String toString() => "PeerConnectionException: $message";
}

class SocketBindException implements Exception {
  final String message;
  SocketBindException([this.message = "No se pudo enlazar el socket (puerto en uso)."]);
  @override
  String toString() => "SocketBindException: $message";
}