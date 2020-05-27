import 'package:flutter/services.dart';

class QrScanController {
  MethodChannel _channel;
  bool _created;

  init(int id) {
    if (_channel == null)
      _channel = MethodChannel('plugin.waibibabo.com/qr_scan_view_$id');
    _created = true;
  }

  /// 开启摄像头
  startCamera() async {
    await _channel?.invokeMethod('startCamera');
  }

  /// 关闭摄像头
  stopCamera() async {
    await _channel?.invokeMethod('stopCamera');
  }

  /// 设置闪光灯
  setFlash(bool flash) async {
    await _channel?.invokeMethod('setFlash', flash);
  }

  /// 切换闪光灯
  toggleFlash() async {
    print('flutter toggleFlash');
    await _channel?.invokeMethod('toggleFlash');
  }

  bool get created => _created;

  /// 获取闪光灯状态
  Future<bool> get flash async => await _channel?.invokeMethod('getFlash');
}
