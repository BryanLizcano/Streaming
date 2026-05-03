import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/chat_viewmodel.dart';
import '../viewmodel/wifi_viewmodel.dart';
import '../widgets/push_to_talk_button.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el estado de la conexión para mostrar el rol (GO o Cliente)
    final wifiVM = context.watch<WifiViewModel>();
    final connectionInfo = wifiVM.currentConnection;

    final role = connectionInfo?.isGroupOwner == true ? "Group Owner" : "Client";

    return Scaffold(
      appBar: AppBar(
        title: Text('Sala P2P ($role)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              wifiVM.disconnect();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Área de Mensajes (TCP)
          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, chatVM, child) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chatVM.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chatVM.messages[index];
                    final isMe = msg.startsWith("Yo:");
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(msg),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Área de Inputs (Texto y PTT)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Entrada de Texto
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Botón Enviar Texto
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (_textController.text.trim().isNotEmpty) {
                      context.read<ChatViewModel>().sendText(_textController.text);
                      _textController.clear();
                    }
                  },
                ),

                // Botón Push-To-Talk (Voz UDP - Fase 2)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: PushToTalkButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}