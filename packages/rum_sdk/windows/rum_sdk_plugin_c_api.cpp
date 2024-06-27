#include "include/rum_sdk/rum_sdk_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "rum_sdk_plugin.h"

void RumSdkPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  rum_sdk::RumSdkPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
