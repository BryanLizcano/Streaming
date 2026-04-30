class PeerDevice {
  final String deviceName;
  final String deviceAddress;
  final bool isGroupOwner;

  PeerDevice({
    required this.deviceName,
    required this.deviceAddress,
    required this.isGroupOwner,
  });
}