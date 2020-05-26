package com.waibibabo.plugin.qr_code

import android.content.Context
import android.view.View
import com.google.zxing.Result
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.platform.PlatformView
import me.dm7.barcodescanner.zxing.ZXingScannerView

class QrScanView(context: Context, messenger: BinaryMessenger, id: Int?, params: Map<String, Any>?)
    : PlatformView,
        ZXingScannerView.ResultHandler, EventChannel.StreamHandler {
    private val view: ZXingScannerView = ZXingScannerView(context)
    private val _channel: EventChannel = EventChannel(messenger, "plugin.waibibabo.com/qr_scan_view_$id")
    private var _events: EventChannel.EventSink? = null

    init {
        view.setAspectTolerance(0.5f)
        view.setResultHandler(this)
        //view.setAutoFocus(true)
        _channel.setStreamHandler(this)
    }

    override fun getView(): View = view
    override fun onFlutterViewAttached(flutterView: View) {
        view.startCamera()
    }

    override fun onFlutterViewDetached() {
        view.stopCamera()
    }

    override fun dispose() {
        _channel.setStreamHandler(null)
        view.stopCamera()
    }

    override fun handleResult(rawResult: Result?) {
        _events?.success(rawResult!!.text)
        view.resumeCameraPreview(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        _events = events
    }

    override fun onCancel(arguments: Any?) {
        _events = null
    }
}