import 'package:flutter/material.dart';
import '../../application/audio/audio_controller.dart';

class VoiceViewModel extends ChangeNotifier {
  final AudioController _audioController;

  bool _isTalking = false;
  bool get isTalking => _isTalking;

  VoiceViewModel(this._audioController) {
    // Inicializamos los servicios de audio en cuanto se crea el ViewModel
    _initialize();
  }

  Future<void> _initialize() async {
    await _audioController.initialize();
  }

  // Se activa al mantener presionado el botón
  Future<void> startTalking(String remoteIp) async {
    if (_isTalking) return;

    _isTalking = true;
    notifyListeners(); // Notifica a la UI para que el botón cambie de color

    await _audioController.startTalking(remoteIp);
  }

  // Se activa al soltar el botón
  Future<void> stopTalking() async {
    if (!_isTalking) return;

    _isTalking = false;
    notifyListeners(); // Notifica a la UI para que el botón vuelva a la normalidad

    await _audioController.stopTalking();
  }

  @override
  void dispose() {
    _audioController.dispose();
    super.dispose();
  }
}