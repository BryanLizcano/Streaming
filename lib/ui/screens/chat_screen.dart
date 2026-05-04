import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/chat_viewmodel.dart';
import '../viewmodel/wifi_viewmodel.dart';
import '../widgets/push_to_talk_button.dart';

import 'discovery_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    context.read<ChatViewModel>().sendText(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final wifiVM = context.watch<WifiViewModel>();
    final chatVM = context.watch<ChatViewModel>();
    final role = wifiVM.currentConnection?.isGroupOwner == true
        ? 'Group Owner'
        : 'Cliente';

    if (chatVM.messages.isNotEmpty) _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        title: Text('Sala P2P ($role)'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _ConnectionBadge(status: chatVM.status),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await context.read<WifiViewModel>().disconnect();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const DiscoveryScreen()),
                      (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: chatVM.messages.isEmpty
                    ? const Center(
                  child: Text(
                    'Aún no hay mensajes',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: chatVM.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chatVM.messages[index];
                    final isSystem = msg.startsWith('🔗');
                    final isMe = msg.startsWith('Yo:');

                    if (isSystem) {
                      return Center(
                        child: Container(
                          margin:
                          const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.purple.withOpacity(0.3)),
                          ),
                          child: Text(
                            msg,
                            style: TextStyle(
                                color: Colors.purple[200], fontSize: 12),
                          ),
                        ),
                      );
                    }

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin:
                        const EdgeInsets.symmetric(vertical: 3),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFF6C3FC4)
                              : const Color(0xFF2A2A3A),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe
                                ? const Radius.circular(16)
                                : const Radius.circular(4),
                            bottomRight: isMe
                                ? const Radius.circular(4)
                                : const Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          msg,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1, color: Color(0xFF2A2A3A)),
              // ── FIX 1: SafeArea en el input para respetar la barra de navegación ──
              // bottom: true → añade padding cuando hay botones físicos/virtuales.
              // En dispositivos con gestos el padding es 0, así que no afecta.
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          enabled: chatVM.isConnected,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: _hintText(chatVM.status),
                            hintStyle:
                            const TextStyle(color: Color(0xFF6B6B8A)),
                            filled: true,
                            fillColor: const Color(0xFF1E1E2E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: (_) => _sendText(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.send,
                            color: Color(0xFF9D6FE8)),
                        onPressed: chatVM.isConnected ? _sendText : null,
                      ),
                      const SizedBox(width: 6),
                      const PushToTalkButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (!chatVM.isConnected)
            _ConnectingOverlay(status: chatVM.status),
        ],
      ),
    );
  }

  String _hintText(ChatConnectionStatus status) => switch (status) {
    ChatConnectionStatus.connecting => 'Conectando…',
    ChatConnectionStatus.waitingForPeer => 'Esperando al otro dispositivo…',
    ChatConnectionStatus.failed => 'Conexión fallida',
    _ => 'Escribe un mensaje…',
  };
}

// ─── Badge de estado ───────────────────────────────────────────────────────────

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.status});
  final ChatConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      ChatConnectionStatus.idle => (Colors.grey, 'Inactivo'),
      ChatConnectionStatus.connecting => (Colors.orange, 'Conectando…'),
      ChatConnectionStatus.waitingForPeer => (Colors.amber, 'Esperando par…'),
      ChatConnectionStatus.connected => (const Color(0xFF9D6FE8), 'Conectado'),
      ChatConnectionStatus.failed => (Colors.red, 'Falló'),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == ChatConnectionStatus.connecting ||
            status == ChatConnectionStatus.waitingForPeer)
          SizedBox(
            width: 10,
            height: 10,
            child:
            CircularProgressIndicator(strokeWidth: 2, color: color),
          )
        else
          Container(
            width: 10,
            height: 10,
            decoration:
            BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

// ─── Overlay semitransparente ──────────────────────────────────────────────────

class _ConnectingOverlay extends StatelessWidget {
  const _ConnectingOverlay({required this.status});
  final ChatConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final isFailed = status == ChatConnectionStatus.failed;
    final isWaiting = status == ChatConnectionStatus.waitingForPeer;

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Card(
          color: const Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isFailed) ...[
                  const Icon(Icons.wifi_off, size: 56, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text('No se pudo conectar',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text(
                    'Verifica que ambos dispositivos estén\ncerca e intenta de nuevo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ] else ...[
                  const SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                        strokeWidth: 5, color: Color(0xFF9D6FE8)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isWaiting
                        ? 'Esperando al otro\ndispositivo…'
                        : 'Estableciendo conexión…',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isWaiting
                        ? 'Ya listo de este lado.\nConecta el otro dispositivo.'
                        : 'Configurando canal de\nmensajes y audio…',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}