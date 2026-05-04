import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  WidgetsFlutterBinding.ensureInitialized();

  // Estilo de la barra de sistema: iconos claros sobre fondo oscuro
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF12121C),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        // =====================================================================
        // 1. CAPA DE INFRAESTRUCTURA
        // =====================================================================
        Provider<WifiRepository>(create: (_) => WifiP2pService()),
        Provider<NetworkRepository>(create: (_) => TcpSocketService()),
        Provider<AudioRepository>(create: (_) => AudioService()),
        Provider<UdpAudioService>(create: (_) => UdpAudioService()),
        Provider<PermissionService>(create: (_) => PermissionService()),

        // =====================================================================
        // 2. CAPA DE APLICACIÓN
        // =====================================================================
        Provider<WifiController>(
          create: (context) => WifiController(context.read<WifiRepository>()),
        ),
        Provider<ChatController>(
          create: (context) =>
              ChatController(context.read<NetworkRepository>()),
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
        ChangeNotifierProvider<ChatViewModel>(
          create: (context) => ChatViewModel(context.read<ChatController>()),
        ),
        ChangeNotifierProvider<VoiceViewModel>(
          create: (context) =>
              VoiceViewModel(context.read<AudioController>()),
        ),
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
    // FIX 3: Tema oscuro/morado minimalista
    // Paleta:
    //   background  #12121C  (casi negro, tinte azul oscuro)
    //   surface     #1E1E2E  (superficie elevada)
    //   primary     #9D6FE8  (morado suave, no chillón)
    //   secondary   #6C3FC4  (morado más profundo para burbujas propias)
    //   onPrimary   blanco
    //   outline     #2A2A3A  (divisores sutiles)
    const Color bgColor = Color(0xFF12121C);
    const Color surfaceColor = Color(0xFF1E1E2E);
    const Color primaryColor = Color(0xFF9D6FE8);
    const Color secondaryColor = Color(0xFF6C3FC4);

    return MaterialApp(
      title: 'P2P Comm Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          background: bgColor,
          surface: surfaceColor,
          primary: primaryColor,
          secondary: secondaryColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Colors.white,
          onSurface: Colors.white,
          outline: Color(0xFF2A2A3A),
          surfaceVariant: Color(0xFF2A2A3A),
          onSurfaceVariant: Color(0xFFB0B0C8),
        ),
        scaffoldBackgroundColor: bgColor,

        // AppBar limpio, sin sombra
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),

        // ListTile
        listTileTheme: const ListTileThemeData(
          tileColor: Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          contentPadding:
          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),

        // Dividers
        dividerTheme: const DividerThemeData(
          color: Color(0xFF2A2A3A),
          thickness: 1,
        ),

        // Cards
        cardTheme: CardThemeData(
          color: surfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2A2A3A)),
          ),
        ),

        // ElevatedButton
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        // SnackBar
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF2A1A4A),
          contentTextStyle: TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
        ),

        // IconButton
        iconTheme: const IconThemeData(color: primaryColor),

        // CircularProgressIndicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primaryColor,
        ),
      ),
      home: const DiscoveryScreen(),
    );
  }
}