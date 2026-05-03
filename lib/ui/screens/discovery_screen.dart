import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/wifi_viewmodel.dart';
import '../../infrastructure/permissions/permission_service.dart';
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
    // Solicitar permisos al arrancar (micrófono, ubicación, Wi-Fi cercano)
    // Sin esto el audio nunca funcionará en Android
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PermissionService>().requestAllRequiredPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos Cercanos'),
        actions: [
          Consumer<WifiViewModel>(
            builder: (context, vm, child) {
              return IconButton(
                icon: Icon(vm.isSearching ? Icons.stop : Icons.search),
                onPressed: () {
                  if (!vm.isSearching) {
                    vm.initializeAndDiscover();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<WifiViewModel>(
        builder: (context, vm, child) {
          if (vm.availablePeers.isEmpty) {
            return const Center(
              child: Text('Buscando dispositivos Wi-Fi Direct...'),
            );
          }

          return ListView.builder(
            itemCount: vm.availablePeers.length,
            itemBuilder: (context, index) {
              final peer = vm.availablePeers[index];
              return ListTile(
                leading: const Icon(Icons.smartphone),
                title: Text(peer.deviceName),
                subtitle: Text(peer.deviceAddress),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await vm.connect(peer);
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatScreen(),
                        ),
                      );
                    }
                  },
                  child: const Text('Conectar'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}