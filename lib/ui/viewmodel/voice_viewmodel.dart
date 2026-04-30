import 'package:flutter/material.dart';
import '../../application/audio/audio_controller.dart';

class VoiceViewModel extends ChangeNotifier {
  final AudioController _audioController;

  bool isTalking = false;

  // Recibe el controlador por inyección de dependencias
  VoiceViewModel(this._audioController) {
    _init();
  }

  Future<void> _init() async {
    // El controlador se encarga de inicializar hardware y enlazar recepción UDP -> Parlante
    await _audioController.initializeAudioSystem();
  }

  // Se llama cuando el usuario MANTIENE PRESIONADO el botón de hablar
  Future<void> startPushToTalk(String targetIpAddress) async {
    isTalking = true;
    notifyListeners();

    // El controlador maneja la captura del micrófono y el envío por UDP
    await _audioController.startTransmission(targetIpAddress);
  }

  // Se llama cuando el usuario SUELTA el botón de hablar
  Future<void> stopPushToTalk() async {
    isTalking = false;
    notifyListeners();

    // El controlador apaga el micrófono y cancela las suscripciones
    await _audioController.stopTransmission();
  }

  @override
  void dispose() {
    _audioController.stopTransmission();
    super.dispose();
  }
}