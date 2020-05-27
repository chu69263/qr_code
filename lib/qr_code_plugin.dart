import 'dart:async';

import 'package:flutter/services.dart';
import 'package:qr_code/qr_result.dart';

import 'qr_result.dart';

class QrCodePlugin {
  static const MethodChannel _channel =
      const MethodChannel('plugin.waibibabo.com/qr_code');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 图片读取二维码
  /// `url` 本地图片路径
  static Future<QrResult> read(String url) async {
    try {
      return QrResult.fromJson(await _channel.invokeMethod('readQr', url));
    } on PlatformException catch (e) {
      print("读图片二维码报错");
      print(e);
      return null;
    }
  }
}
