package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import cz.analogic.multicastlock.MulticastLockPlugin;
import io.anire.peardrop.PeardropPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    MulticastLockPlugin.registerWith(registry.registrarFor("cz.analogic.multicastlock.MulticastLockPlugin"));
    PeardropPlugin.registerWith(registry.registrarFor("io.anire.peardrop.PeardropPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
