import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  Future<bool> requestAllRequiredPermissions() async {
    Map<Permission, PermissionStatus> statuses = {};

    if (Platform.isAndroid) {
      statuses = await [
        Permission.location,
        Permission.nearbyWifiDevices, // Requerido para Android 13+ (P2P)
        Permission.microphone,        // Para la Fase 2 (Audio)
      ].request();
    } else if (Platform.isIOS) {
      statuses = await [
        Permission.location,
        Permission.microphone,
      ].request();
    }

    // Verificar si todos los permisos solicitados fueron concedidos
    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        allGranted = false;
        print('Permiso denegado: $permission');
      }
    });

    return statuses.values.every((status) => status.isGranted);
  }
}