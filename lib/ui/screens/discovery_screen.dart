import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/model/peer_device.dart';
import '../../infrastructure/permissions/permission_service.dart';
import '../viewmodel/wifi_viewmodel.dart';
import 'chat_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  bool _permissionsGranted = false;
  bool _checkingPermissions = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestPermissionsAndInit());
  }

  /// Lógica extraída para poder reutilizarla desde el botón "Volver a intentar"
  Future<void> _requestPermissionsAndInit() async {
    setState(() => _checkingPermissions = true);

    final permService = context.read<PermissionService>();
    final granted = await permService.requestAllRequiredPermissions();

    if (!mounted) return;
    setState(() {
      _permissionsGranted = granted;
      _checkingPermissions = false;
    });

    if (granted) {
      final wifiVM = context.read<WifiViewModel>();
      wifiVM.initializeAndDiscover();
      wifiVM.addListener(_connectionListener);
    }
  }

  void _connectionListener() {
    final wifiVM = context.read<WifiViewModel>();
    if (wifiVM.currentConnection?.isConnected == true && mounted) {
      wifiVM.removeListener(_connectionListener);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      );
    }
  }

  @override
  void dispose() {
    try {
      context.read<WifiViewModel>().removeListener(_connectionListener);
    } catch (_) {}
    super.dispose();
  }

  void _onPeerTapped(PeerDevice device) async {
    final vm = context.read<WifiViewModel>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Conectando con ${device.deviceName}…"),
        backgroundColor: const Color(0xFF2A1A4A),
      ),
    );
    try {
      await vm.connect(device);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo iniciar la conexión")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WifiViewModel>();

    // Mientras verificamos permisos
    if (_checkingPermissions) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF9D6FE8)),
              SizedBox(height: 16),
              Text('Verificando permisos…',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    // Si el usuario rechazó permisos
    if (!_permissionsGranted) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    size: 64, color: Color(0xFF9D6FE8)),
                const SizedBox(height: 20),
                const Text(
                  'Permisos necesarios',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Esta app necesita acceso a ubicación, micrófono y Wi-Fi cercano para funcionar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Volver a intentar'),
                  onPressed: _requestPermissionsAndInit,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Pantalla normal de descubrimiento
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos Cercanos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => vm.initializeAndDiscover(),
          ),
        ],
      ),
      body: vm.availablePeers.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (vm.isSearching) ...[
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                    color: Color(0xFF9D6FE8), strokeWidth: 3),
              ),
              const SizedBox(height: 16),
              const Text('Buscando dispositivos Wi-Fi Direct…',
                  style: TextStyle(color: Colors.grey)),
            ] else
              const Text('No se encontraron dispositivos',
                  style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: vm.availablePeers.length,
        itemBuilder: (context, index) {
          final device = vm.availablePeers[index];
          return ListTile(
            leading: const Icon(Icons.devices,
                color: Color(0xFF9D6FE8)),
            title: Text(device.deviceName,
                style: const TextStyle(color: Colors.white)),
            subtitle: Text(device.deviceAddress,
                style: const TextStyle(color: Colors.grey)),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
            onTap: () => _onPeerTapped(device),
          );
        },
      ),
    );
  }
}