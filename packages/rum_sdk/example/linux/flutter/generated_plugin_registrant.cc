//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <rum_sdk/rum_sdk_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) rum_sdk_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "RumSdkPlugin");
  rum_sdk_plugin_register_with_registrar(rum_sdk_registrar);
}
