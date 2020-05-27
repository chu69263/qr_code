import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code/qr_code_plugin.dart';
import 'package:qr_code/qr_result.dart';
import 'package:qr_code/qr_scan_controller.dart';
import 'package:qr_code/qr_scan_view.dart';
import 'package:uuid/uuid.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await QrCodePlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Wrap(
            direction: Axis.vertical,
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              Builder(builder: (context) {
                return RaisedButton(
                  child: Text('相机扫码'),
                  onPressed: () async {
                    var result = await Navigator.of(context).push<QrResult>(
                      MaterialPageRoute(builder: (_) => QrScanPage()),
                    );
                    if (result != null) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result.text),
                        ),
                      );
                    }
                  },
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}

class QrScanPage extends StatefulWidget {
  @override
  _QrScanPageState createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  var controller = QrScanController();
  var _text = '测试文本';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          QrScanView(
            controller: controller,
            onResult: (r) {
//              setState(() {
//                _text = r.text;
//              });
              Navigator.pop(context, r);
            },
          ),
          Center(
            child: Text(
              _text,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () {
                controller.toggleFlash();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('切换闪光灯'),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: RaisedButton(
              onPressed: readQr,
              child: Text('相册'),
            ),
          )
        ],
      ),
    );
  }

  readQr() async {
    var assets = await MultiImagePicker.pickImages(maxImages: 1);
    if (assets.length == 0) return;
    var asset = assets[0];
    var size = getSize(
      Size(1000, 1000),
      Size(asset.originalWidth.toDouble(), asset.originalHeight.toDouble()),
    );
    var bd =
        await asset.getThumbByteData(size.width.toInt(), size.height.toInt());
    var path = await saveTempFile(bd.buffer.asUint8List());
    var result = await QrCodePlugin.read(path);
    if (result != null) Navigator.pop(context, result);
  }

  Size getSize(Size container, Size original) {
    if (original.width <= container.width &&
        original.height <= container.height) return original;
    var ratio = original.aspectRatio;
    var width = container.width;
    var height = container.height;
    if (ratio >= container.aspectRatio) {
      // 宽度>=高度，宽度占满
      height = width / ratio;
    } else {
      // 宽度<高度，高度占满
      width = height * ratio;
    }
    return Size(width, height);
  }

  /// 保存临时文件
  Future<String> saveTempFile(List<int> data, {String fileName}) async {
    var dir = await getTemporaryDirectory();
    fileName ??= Uuid().v4();
    try {
      var file = await File('${dir.path}/$fileName').writeAsBytes(data);
      return file.path;
    } catch (e) {
      print('MediaHelper.saveImageFile error');
      print(e);
      return null;
    }
  }
}
