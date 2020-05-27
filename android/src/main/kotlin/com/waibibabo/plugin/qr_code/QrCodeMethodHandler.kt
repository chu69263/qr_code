package com.waibibabo.plugin.qr_code

import android.graphics.BitmapFactory
import com.google.zxing.BinaryBitmap
import com.google.zxing.DecodeHintType
import com.google.zxing.RGBLuminanceSource
import com.google.zxing.common.HybridBinarizer
import com.google.zxing.qrcode.QRCodeReader
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

class QrCodeMethodHandler : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "readQr" -> {
                try {
                    var text = decodeQrCode(call.arguments as String)
                    result.success(hashMapOf<String, Any>("code" to 1, "text" to text))
                } catch (e: Exception) {
                    result.error("0", e.message, e)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}

fun decodeQrCode(path: String): String {
    var tmpPath = path
    if (path.startsWith("file://")) {
        tmpPath = path.replace("file://", "")
    }
    var bitmap = BitmapFactory.decodeFile(tmpPath)
    var w = bitmap.width
    var h = bitmap.height
    var pixels = IntArray(w * h)
    bitmap.getPixels(pixels, 0, w, 0, 0, w, h)
    var b = BinaryBitmap(HybridBinarizer(RGBLuminanceSource(w, h, pixels)))
    val hints: Hashtable<DecodeHintType, String> = Hashtable<DecodeHintType, String>()
    hints[DecodeHintType.CHARACTER_SET] = "utf-8"
    try {
        return QRCodeReader().decode(b, hints).text
    } finally {
        if (!bitmap.isRecycled)
            bitmap.recycle()
    }
}