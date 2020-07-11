package de.pdad.getip

import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.net.NetworkInterface
import java.util.*

class GetIpPlugin(): MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar): Unit {
      val channel = MethodChannel(registrar.messenger(), "get_ip")
      channel.setMethodCallHandler(GetIpPlugin())
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result): Unit {
    if (call.method.equals("getIpAdress")) {
      result.success(getIPAddress(true))
    } else if (call.method.equals("getIpV6Adress")) {
      result.success(getIPAddress(false))
    } else {
      result.notImplemented()
    }
  }

  fun getIPAddress(useIPv4: Boolean): String {
    try {
      val interfaces = Collections.list(NetworkInterface.getNetworkInterfaces())
      for (intf in interfaces) {
        val addrs = Collections.list(intf.getInetAddresses())
        for (addr in addrs) {
          if (!addr.isLoopbackAddress()) {
            val sAddr = addr.getHostAddress()
            //boolean isIPv4 = InetAddressUtils.isIPv4Address(sAddr);
            val isIPv4 = sAddr.indexOf(':') < 0

            if (useIPv4) {
              if (isIPv4)
                return sAddr
            } else {
              if (!isIPv4) {
                val delim = sAddr.indexOf('%') // drop ip6 zone suffix
                return if (delim < 0) sAddr.toUpperCase() else sAddr.substring(0, delim).toUpperCase()
              }
            }
          }
        }
      }
    } catch (e: Exception) {
      print(e);
    }
    return ""
  }
}
