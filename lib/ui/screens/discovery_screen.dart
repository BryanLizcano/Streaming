import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/model/peer_device.dart';
import '../viewmodel/wifi_viewmodel.dart';
import 'chat_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wifiVM = context.read<WifiViewModel>();

      // 🟢 USAMOS TU MÉTODO REAL
      wifiVM.initializeAndDiscover();

      // Agregamos el listener de navegación automática
      wifiVM.addListener(_connectionListener);
    });
  }

  void _connectionListener() {
    final wifiVM = context.read<WifiViewModel>();

    // 🟢 USAMOS TU VARIABLE 'currentConnection'
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

    try {
      // 🟢 USAMOS TU MÉTODO 'connect' QUE RECIBE EL DISPOSITIVO
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dispositivos Cercanos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => vm.initializeAndDiscover(),
          ),
        ],
      ),
      // 🟢 USAMOS TU LISTA 'availablePeers'
      body: vm.availablePeers.isEmpty
          ? const Center(child: Text("Buscando dispositivos Wi-Fi Direct..."))
          : ListView.builder(
        itemCount: vm.availablePeers.length,
        itemBuilder: (context, index) {
          final device = vm.availablePeers[index];
          return ListTile(
            leading: const Icon(Icons.devices),
            title: Text(device.deviceName),
            subtitle: Text(device.deviceAddress),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _onPeerTapped(device),
          );
        },
      ),
    );
  }
}