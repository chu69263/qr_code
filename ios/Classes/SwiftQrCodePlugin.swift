import Flutter
import UIKit
import AVFoundation

public class SwiftQrCodePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "plugin.waibibabo.com/qr_code", binaryMessenger: registrar.messenger())
        let instance = SwiftQrCodePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        let f = QrScanViewFactory(binaryMessenger: registrar.messenger())
        registrar.register(f, withId: "plugin.waibibabo.com/qr_scan_view")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "readQr":
            do{
                let text = try readQr(path: call.arguments as! String)
                if text == nil{
                    result(nil)
                }
                else{
                    result(["code":1,"text":text!])
                }
            }catch{
                result(nil)
            }
            
        default:
            result("notImplemented")
        }
    }
}

func readQr(path:String) throws -> String?{
    let image = CIImage(contentsOf: URL(string:"file://\(path)")!)
    let context = CIContext(options: nil)
    let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context,
                              options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
    let features = detector?.features(in: image!)
    for feature in features as! [CIQRCodeFeature] {
        return feature.messageString!
    }
    return nil
}
