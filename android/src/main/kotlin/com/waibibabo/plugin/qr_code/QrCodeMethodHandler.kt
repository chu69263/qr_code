package com.waibibabo.plugin.qr_code

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class QrCodeMethodHandler : MethodChannel.MethodCallHandler {
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else {
            result.notImplemented()
        }
    }
}