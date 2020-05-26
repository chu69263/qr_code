package com.waibibabo.plugin.qr_code

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar

/** QrCodePlugin */
public class QrCodePlugin : FlutterPlugin {
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "plugin.waibibabo.com/qr_code")
        channel.setMethodCallHandler(QrCodeMethodHandler());
        flutterPluginBinding.platformViewRegistry.registerViewFactory("plugin.waibibabo.com/qr_scan_view", QrScanViewFactory(flutterPluginBinding.binaryMessenger))
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "plugin.waibibabo.com/qr_code")
            channel.setMethodCallHandler(QrCodeMethodHandler())
            registrar.platformViewRegistry().registerViewFactory("plugin.waibibabo.com/qr_scan_view", QrScanViewFactory(registrar.messenger()))
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    }
}
