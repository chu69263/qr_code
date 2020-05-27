package com.waibibabo.plugin.qr_code

import android.content.Context
import android.view.View
import com.google.zxing.Result
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import me.dm7.barcodescanner.zxing.ZXingScannerView

class QrScanView(context: Context, messenger: BinaryMessenger, id: Int?, params: Map<String, Any>?)
    : PlatformView,
        ZXingScannerView.ResultHandler, EventChannel.StreamHandler, MethodChannel.MethodCallHandler {
    private val view: ZXingScannerView = ZXingScannerView(context)
    private val methodChannel: MethodChannel = MethodChannel(messenger, "plugin.waibibabo.com/qr_scan_view_$id")
    private val eventChannel: EventChannel = EventChannel(messenger, "plugin.waibibabo.com/qr_scan_view_$id/event")
    private var _events: EventChannel.EventSink? = null

    init {
        view.setAspectTolerance(0.5f)
        view.setResultHandler(this)
        view.setAutoFocus(true)
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun getView(): View = view
    override fun onFlutterViewAttached(flutterView: View) {
        view.startCamera()
    }

    override fun onFlutterViewDetached() {
        view.stopCamera()
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        view.stopCamera()
    }

    override fun handleResult(rawResult: Result?) {
        val map = hashMapOf<String, Any>("code" to 1, "text" to rawResult!!.text)
        _events?.success(map)
        //view.resumeCameraPreview(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        _events = events
    }

    override fun onCancel(arguments: Any?) {
        _events = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startCamera" -> {
                view.startCamera()
                result.success(null)
            }
            "stopCamera" -> {
                view.stopCamera()
                result.success(null)
            }
            "setFlash" -> {
                view.flash = call.arguments as Boolean
                result.success(null)
            }
            "toggleFlash" -> {
                view.toggleFlash()
                result.success(null)
            }
            "getFlash" -> {
                result.success(view.flash)
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}