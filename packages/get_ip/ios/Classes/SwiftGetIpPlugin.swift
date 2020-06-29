import Flutter
import UIKit


public class SwiftGetIpPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "get_ip", binaryMessenger: registrar.messenger())
    let instance = SwiftGetIpPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let ip =  getWiFiAddress(ipAddressType:call.method)
    result(ip)
  }

  // Return IP address of WiFi interface (en0) as a String, or `nil`
    public func getWiFiAddress(ipAddressType:String) -> String? {
        var address : String?
        var targetAddrFamily : UInt8?
        
        if ipAddressType == "getIpV6Adress" {
            targetAddrFamily = UInt8(AF_INET6)
        } else{
            targetAddrFamily = UInt8(AF_INET)
        }

        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == targetAddrFamily {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address

  }
}
