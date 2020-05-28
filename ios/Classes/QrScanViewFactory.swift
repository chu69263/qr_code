//
//  QrScanViewFactory.swift
//  qr_code
//
//  Created by 逍遥游 on 2020/5/27.
//

import Foundation
import Flutter
class QrScanViewFactory: NSObject, FlutterPlatformViewFactory {
    let binaryMessenger:FlutterBinaryMessenger
    init(binaryMessenger:FlutterBinaryMessenger) {
        self.binaryMessenger = binaryMessenger
    }
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return QrScanView(binaryMessenger:binaryMessenger,frame:frame, viewId:viewId, args:args)
    }
    
}
