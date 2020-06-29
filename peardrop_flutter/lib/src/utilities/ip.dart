import 'dart:io';

Future<bool> isSelfIP(InternetAddress ip) async {
  // Get IPs
  final ips = await getAllIPs();
  return ips.contains(ip);
}

Future<Set<InternetAddress>> getAllIPs() async {
  final interfaces = await NetworkInterface.list();
  return interfaces.expand((interface) => interface.addresses).toSet();
}

Future<InternetAddress> getMainIP() async {
  final interfaces = await NetworkInterface.list();
  for (final interface in interfaces) {
    // Find IPv4 otherwise fallback to IPv6, otherwise continue
    final ipv4Address = interface.addresses.where((address) => address.type == InternetAddressType.IPv4);
    if (ipv4Address.isNotEmpty) return ipv4Address.first;
    final ipv6Address = interface.addresses.where((address) => address.type == InternetAddressType.IPv6);
    if (ipv6Address.isNotEmpty) return ipv6Address.first;
  }
  return null;
}