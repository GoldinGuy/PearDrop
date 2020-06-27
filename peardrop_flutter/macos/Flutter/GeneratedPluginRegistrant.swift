//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import menubar
import window_size
import file_chooser
import path_provider_macos
import shared_preferences_macos
import url_launcher_macos
import libpeardrop

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  MenubarPlugin.register(with: registry.registrar(forPlugin: "MenubarPlugin"))
  WindowSizePlugin.register(with: registry.registrar(forPlugin: "WindowSizePlugin"))
  FileChooserPlugin.register(with: registry.registrar(forPlugin: "FileChooserPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  UrlLauncherPlugin.register(with: registry.registrar(forPlugin: "UrlLauncherPlugin"))
  PeardropPlugin.register(with: registry.registrar(forPlugin: "PeardropPlugin"))
}
