import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:sound_stream/sound_stream.dart';
import '../../domain/repository/audio_repository.dart';

class AudioService implements AudioRepository {
  final AudioRecorder _recorder = AudioRecorder();
  final PlayerStream _player = PlayerStream();

  @override
  Future<void> initialize() async {
    // Es vital inicializar el reproductor antes de recibir nada
    await _player.initialize();
    await _player.start();
  }

  @override
  Future<Stream<Uint8List>> startRecordingStream() async {
    // Configuración exacta para Walkie-Talkie (Voz clara, poco peso)
    const config = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
    );
    return await _recorder.startStream(config);
  }

  @override
  Future<void> playAudioChunk(List<int> chunk) async {
    // Él inyecta los bytes directamente al reproductor
    _player.writeChunk(Uint8List.fromList(chunk));
  }

  @override
  Future<void> stopRecording() async => await _recorder.stop();
}