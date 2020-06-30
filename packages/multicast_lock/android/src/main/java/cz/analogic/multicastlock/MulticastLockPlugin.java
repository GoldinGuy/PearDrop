package cz.analogic.multicastlock;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import android.app.Activity;
import android.os.Build;
import android.content.Context;
import android.net.wifi.WifiManager;

/** MulticastLockPlugin */
public class MulticastLockPlugin implements MethodCallHandler {
  private static final String CHANNEL = "multicast_lock";
  private WifiManager.MulticastLock multicastLock;
  private final Activity activity;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "multicast_lock");
    channel.setMethodCallHandler(new MulticastLockPlugin(registrar.activity()));
  }

  private MulticastLockPlugin(Activity activity) {
    this.activity = activity;
  }

  public void onMethodCall(MethodCall call, Result result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.DONUT) {
      result.error("UNAVAILABLE", "Obsolete android version", null);
      return;
    }

    if (call.method.equals("acquire")) {
      if(acquire()) {
        result.success(null);
      } else {
        result.error("UNAVAILABLE", "WifiManager not present", null);
      }
    } else if (call.method.equals("release")) {
      if(release()) {
        result.success(null);
      } else {
        result.error("UNAVAILABLE", "Lock is already released", null);
      }
    } else if (call.method.equals("isHeld")) {
      result.success(isHeld());
    } else {
      result.notImplemented();
    }
  }

  private boolean acquire() throws NullPointerException
  {
    WifiManager wifi = (WifiManager) activity.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
    if(wifi == null) {
      return false;
    }

    multicastLock = wifi.createMulticastLock("discovery");
    multicastLock.acquire();

    return true;
  }

  private boolean release() {
    try {
      multicastLock.release();
    } catch(RuntimeException e) {
      return false;
    }

    return true;
  }

  private boolean isHeld() {
    return multicastLock.isHeld();
  }
}
