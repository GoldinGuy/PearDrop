import Flutter
import UIKit

public class SwiftPeardropPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {}

  public func dummyMethodToEnforceBinding() {
    // This should never be executed
    ackpacket_free(nil)
    adpacket_free(nil)
    senderpacket_free(nil)
    string_free(nil)
  }
}
