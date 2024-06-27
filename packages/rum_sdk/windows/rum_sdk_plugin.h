#ifndef FLUTTER_PLUGIN_RUM_SDK_PLUGIN_H_
#define FLUTTER_PLUGIN_RUM_SDK_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace rum_sdk {

class RumSdkPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  RumSdkPlugin();

  virtual ~RumSdkPlugin();

  // Disallow copy and assign.
  RumSdkPlugin(const RumSdkPlugin&) = delete;
  RumSdkPlugin& operator=(const RumSdkPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace rum_sdk

#endif  // FLUTTER_PLUGIN_RUM_SDK_PLUGIN_H_
