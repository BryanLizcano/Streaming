import 'dart:typed_data';

abstract class AudioRepository {
  Future<void> initialize();
  Future<Stream<Uint8List>> startRecordingStream();
  Future<void> stopRecording();
  Future<void> playAudioChunk(List<int> chunk);
}