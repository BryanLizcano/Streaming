import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/voice_viewmodel.dart';
import '../viewmodel/wifi_viewmodel.dart';
import '../viewmodel/chat_viewmodel.dart';

class PushToTalkButton extends StatelessWidget {
  const PushToTalkButton({super.key});

  @override
  Widget build(BuildContext context) {
    final voiceVM = context.watch<VoiceViewModel>();
    final wifiVM = context.read<WifiViewModel>();
    final chatVM = context.read<ChatViewModel>();

    final isGroupOwner = wifiVM.currentConnection?.isGroupOwner ?? false;

    // Determinar la IP de destino para el audio UDP:
    //   - Si soy GO: envío al cliente → IP capturada cuando el cliente se conectó al servidor TCP
    //   - Si soy Cliente: envío al GO → groupOwnerAddress (siempre 192.168.49.1 en Wi-Fi Direct)
    final targetIp = isGroupOwner
        ? (chatVM.peerIp ?? '192.168.49.2')
        : (wifiVM.currentConnection?.groupOwnerAddress ?? '192.168.49.1');

    return GestureDetector(
      onTapDown: (_) => voiceVM.startPushToTalk(targetIp),
      onTapUp: (_) => voiceVM.stopPushToTalk(),
      onTapCancel: () => voiceVM.stopPushToTalk(),
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
              ),
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