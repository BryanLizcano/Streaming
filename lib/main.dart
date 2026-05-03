import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Dominio (Contratos) ---
import 'domain/repository/audio_repository.dart';
import 'domain/repository/network_repository.dart';
import 'domain/repository/wifi_repository.dart';

// --- Infraestructura (Implementaciones y Servicios) ---
import 'infrastructure/audio/audio_service.dart';
import 'infrastructure/audio/udp_audio_service.dart';
import 'infrastructure/network/tcp_socket_service.dart';
import 'infrastructure/permissions/permission_service.dart';
import 'infrastructure/wifi/wifi_p2p_service.dart';

// --- Aplicación (Controladores / Casos de Uso) ---
import 'application/audio/audio_controller.dart';
import 'application/chat/chat_controller.dart';
import 'application/wifi/wifi_controller.dart';

// --- UI (ViewModels y Pantallas) ---
import 'ui/screens/discovery_screen.dart';
import 'ui/viewmodel/chat_viewmodel.dart';
import 'ui/viewmodel/voice_viewmodel.dart';
import 'ui/viewmodel/wifi_viewmodel.dart';

void main() async {
  // Necesario para inicializar bindings nativos antes de correr la app (ej. Permisos, AudioTrack)
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        // =====================================================================
        // 1. CAPA DE INFRAESTRUCTURA (Repositorios y Servicios Core)
        // =====================================================================
        Provider<WifiRepository>(create: (_) => WifiP2pService()),
        Provider<NetworkRepository>(create: (_) => TcpSocketService()),
        Provider<AudioRepository>(create: (_) => AudioService()),
        Provider<UdpAudioService>(create: (_) => UdpAudioService()),
        Provider<PermissionService>(create: (_) => PermissionService()),

        // =====================================================================
        // 2. CAPA DE APLICACIÓN (Controladores / Lógica de Negocio)
        // =====================================================================
        // Inyectamos la infraestructura dentro de los controladores
        Provider<WifiController>(
          create: (context) => WifiController(context.read<WifiRepository>()),
        ),
        Provider<ChatController>(
          create: (context) => ChatController(context.read<NetworkRepository>()),
        ),
        Provider<AudioController>(
          create: (context) => AudioController(
            context.read<AudioRepository>(),
            context.read<UdpAudioService>(),
          ),
        ),

        // =====================================================================
        // 3. CAPA DE PRESENTACIÓN (ViewModels)
        // =====================================================================
        // Inyectamos los controladores dentro de los ViewModels
        ChangeNotifierProvider<ChatViewModel>(
          create: (context) => ChatViewModel(context.read<ChatController>()),
        ),
        ChangeNotifierProvider<VoiceViewModel>(
          create: (context) => VoiceViewModel(context.read<AudioController>()),
        ),

        // WifiViewModel necesita el WifiController para escanear, pero también
        // necesita el ChatViewModel para iniciar los sockets cuando se conecta.
        ChangeNotifierProvider<WifiViewModel>(
          create: (context) => WifiViewModel(
            context.read<WifiController>(),
            context.read<ChatViewModel>(),
          ),
        ),
      ],
      child: const P2pCommunicationApp(),
    ),
  );
}

class P2pCommunicationApp extends StatelessWidget {
  const P2pCommunicationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P2P Comm Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DiscoveryScreen(),
    );
  }
}