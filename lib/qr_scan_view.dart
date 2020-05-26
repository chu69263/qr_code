import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class QrScanView extends StatefulWidget {
  final ValueChanged<String> onResult;

  const QrScanView({Key key, this.onResult}) : super(key: key);

  @override
  _QrScanViewState createState() => _QrScanViewState();
}

class _QrScanViewState extends State<QrScanView> {
  StreamSubscription _handleResult;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: 'plugin.waibibabo.com/qr_scan_view',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text('不支持的平台');
  }

  _onPlatformViewCreated(int id) {
    EventChannel channel =
        EventChannel('plugin.waibibabo.com/qr_scan_view_$id');
    _handleResult = channel.receiveBroadcastStream().listen((r) {
      print('扫描结果$r');
      widget.onResult?.call(r);
    });
  }

  @override
  void dispose() {
    _handleResult?.cancel();
    super.dispose();
  }
}
