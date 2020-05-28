import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_code/qr_scan_controller.dart';

import 'qr_result.dart';

class QrScanView extends StatefulWidget {
  final ValueChanged<QrResult> onResult;
  final QrScanController controller;

  const QrScanView({
    Key key,
    this.onResult,
    @required this.controller,
  }) : super(key: key);

  @override
  _QrScanViewState createState() => _QrScanViewState();
}

class _QrScanViewState extends State<QrScanView> with WidgetsBindingObserver {
  StreamSubscription _handleResult;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: 'plugin.waibibabo.com/qr_scan_view',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: 'plugin.waibibabo.com/qr_scan_view',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text('不支持的平台');
  }

  _onPlatformViewCreated(int id) {
    widget.controller?.init(id);
    EventChannel channel =
        EventChannel('plugin.waibibabo.com/qr_scan_view_$id/event');
    _handleResult = channel.receiveBroadcastStream().listen((r) {
      print('扫描结果$r');
      widget.onResult?.call(QrResult.fromJson(r));
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        widget.controller.startCamera();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        widget.controller.stopCamera();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    _handleResult?.cancel();
  }
}
