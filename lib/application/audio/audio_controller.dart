import 'dart:async';
import 'dart:typed_data';
import '../../domain/repository/audio_repository.dart';
import '../../infrastructure/audio/udp_audio_service.dart';

class AudioController {
  final AudioRepository _audioRepository;
  final UdpAudioService _udpAudioService;

  StreamSubscription? _recorderSubscription;
  StreamSubscription? _receiverSubscription;

  AudioController(this._audioRepository, this._udpAudioService);

  // 1. Inicialización: Prepara el altavoz y el receptor UDP
  Future<void> initialize() async {
    await _audioRepository.initialize(); // Inicializa PlayerStream
    await _udpAudioService.init();       // Inicializa Socket UDP

    // 🟢 CORRECCIÓN AQUÍ: Usamos .audioStream en lugar de .listen()
    _receiverSubscription = _udpAudioService.audioStream.listen((List<int> chunk) {
      _audioRepository.playAudioChunk(chunk);
    });
  }

  // 2. Iniciar Walkie-Talkie (Al presionar el botón)
  Future<void> startTalking(String remoteIp) async {
    try {
      final audioStream = await _audioRepository.startRecordingStream();

      _recorderSubscription = audioStream.listen((Uint8List chunk) {
        // Enviamos cada pedacito de voz a la IP remota
        _udpAudioService.send(chunk, remoteIp);
      });
    } catch (e) {
      print("Error al empezar a hablar: $e");
    }
  }

  // 3. Detener Walkie-Talkie (Al soltar el botón)
  Future<void> stopTalking() async {
    await _recorderSubscription?.cancel();
    await _audioRepository.stopRecording();
  }

  // Limpieza total al salir de la app
  void dispose() {
    _recorderSubscription?.cancel();
    _receiverSubscription?.cancel();
    _udpAudioService.dispose();
  }
}