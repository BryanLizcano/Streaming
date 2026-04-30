import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:sound_stream/sound_stream.dart';
import '../../domain/repository/audio_repository.dart';

class AudioService implements AudioRepository {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final PlayerStream _playerStream = PlayerStream();

  @override
  Future<void> initialize() async {
    // Inicializa el AudioTrack nativo de Android
    await _playerStream.initialize();
  }

  @override
  Future<Stream<Uint8List>> startRecordingStream() async {
    // Configuramos PCM 16 bits (estándar para AudioRecord en Android)
    // Usamos 16000 Hz para balancear calidad de voz y ancho de banda en UDP
    final stream = await _audioRecorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );
    return stream;
  }

  @override
  Future<void> stopRecording() async {
    await _audioRecorder.stop();
  }

  @override
  Future<void> playAudioChunk(List<int> chunk) async {
    if (chunk.isNotEmpty) {
      // Reproducir el fragmento PCM inmediatamente usando AudioTrack
      _playerStream.writeChunk(Uint8List.fromList(chunk));
    }
  }
}