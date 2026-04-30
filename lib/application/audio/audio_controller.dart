import 'dart:async';
import 'dart:typed_data';
import '../../domain/repository/audio_repository.dart';
import '../../infrastructure/audio/udp_audio_service.dart';

class AudioController {
  final AudioRepository _audioRepository;
  final UdpAudioService _udpAudioService;
  StreamSubscription? _recordingSub;

  AudioController(this._audioRepository, this._udpAudioService);

  Future<void> initializeAudioSystem() async {
    await _audioRepository.initialize();
    await _udpAudioService.initUdpReceiver();

    // Conectar la recepción de red con la reproducción de hardware
    _udpAudioService.audioStream.listen((chunk) {
      _audioRepository.playAudioChunk(chunk);
    });
  }

  Future<void> startTransmission(String targetIp) async {
    final stream = await _audioRepository.startRecordingStream();

    _recordingSub = stream.listen((Uint8List chunk) {
      _udpAudioService.sendAudioBuffer(chunk, targetIp);
    });
  }

  Future<void> stopTransmission() async {
    await _recordingSub?.cancel();
    await _audioRepository.stopRecording();
  }
}