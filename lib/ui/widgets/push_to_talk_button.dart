import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/voice_viewmodel.dart';
import '../viewmodel/wifi_viewmodel.dart';

class PushToTalkButton extends StatelessWidget {
  const PushToTalkButton({super.key});

  @override
  Widget build(BuildContext context) {
    final voiceVM = context.watch<VoiceViewModel>();
    final wifiVM = context.read<WifiViewModel>();

    // Obtenemos la IP de destino basada en la conexión actual
    // Si eres Cliente, mandas a la IP del Group Owner.
    // Si eres el Group Owner, deberías gestionar la IP del cliente (simplificado aquí)
    final targetIp = wifiVM.currentConnection?.groupOwnerAddress ?? '192.168.49.1';

    return GestureDetector(
      onTapDown: (_) => voiceVM.startPushToTalk(targetIp), // Presiona
      onTapUp: (_) => voiceVM.stopPushToTalk(),            // Suelta
      onTapCancel: () => voiceVM.stopPushToTalk(),         // Cancela (ej. desliza el dedo)
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: voiceVM.isTalking ? Colors.red : Colors.blue,
          boxShadow: [
            if (voiceVM.isTalking)
              const BoxShadow(
                color: Colors.redAccent,
                blurRadius: 15,
                spreadRadius: 5,
              )
          ],
        ),
        child: const Icon(
          Icons.mic,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}