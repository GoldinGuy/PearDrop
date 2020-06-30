import 'dart:io';

import 'package:get_ip/get_ip.dart';

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
  if (Platform.isIOS || Platform.isAndroid) {
    final ipv4Address = await GetIp.ipAddress;
    if (ipv4Address != null) return InternetAddress(ipv4Address);
    final ipv6Address = await GetIp.ipv6Address;
    if (ipv6Address != null) return InternetAddress(ipv6Address);
    return null;
  }
  final interfaces = await NetworkInterface.list();
  for (final interface in interfaces) {
    print(
        'Interface name = ${interface.name}, addresses = ${interface.addresses}');
    final ipv4Address = interface.addresses.firstWhere(
        (address) => address.type == InternetAddressType.IPv4,
        orElse: () => null);
    if (ipv4Address != null) return ipv4Address;
    final ipv6Address = interface.addresses.firstWhere(
        (address) => address.type == InternetAddressType.IPv6,
        orElse: () => null);
    if (ipv6Address != null) return ipv6Address;
  }
  return null;
}
