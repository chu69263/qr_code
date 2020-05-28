//
//  QrScanView.swift
//  qr_code
//
//  Created by 逍遥游 on 2020/5/27.
//

import AVFoundation


class QrScanView: NSObject, FlutterPlatformView,FlutterStreamHandler,AVCaptureMetadataOutputObjectsDelegate{
    
    var mView : ScanInnerView!
    var eventChannel:FlutterEventChannel!
    var methodChannel:FlutterMethodChannel!
    
    
    init(binaryMessenger:FlutterBinaryMessenger,frame:CGRect, viewId:Int64, args: Any?) {
        super.init()
        mView = ScanInnerView(frame:frame,outputDelegate: self)
        methodChannel = FlutterMethodChannel(name:"plugin.waibibabo.com/qr_scan_view_\(viewId)",binaryMessenger: binaryMessenger)
        eventChannel = FlutterEventChannel(name:"plugin.waibibabo.com/qr_scan_view_\(viewId)/event",binaryMessenger: binaryMessenger)
        methodChannel.setMethodCallHandler({ call, result in
            switch call.method {
            case "startCamera":
                self.mView.startCamera()
                result(nil)
            case "stopCamera":
                self.mView.stopCamera()
                result(nil)
            case "setFlash":
                self.mView.setFlash(flash: call.arguments as! Bool)
                result(nil)
            case "getFlash":
                result(self.mView.getFlash())
            case "toggleFlash":
                self.mView.toggleFlash()
                result(nil)
            default:
                result(nil)
            }
        })
        eventChannel.setStreamHandler(self)
    }
    
    private var eventSink:FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            print("扫码：",stringValue)
            mView.stopCamera()
            eventSink?(["code":1,"text":stringValue])
        }
    }
    
    func view() -> UIView {
        return mView
    }
}

class ScanInnerView: UIView {
    var session:AVCaptureSession!
    var previewLayer:AVCaptureVideoPreviewLayer!
    var overlay:QrScanOverlay!
    var outputDelegate:AVCaptureMetadataOutputObjectsDelegate!
    
    init(frame: CGRect,outputDelegate:AVCaptureMetadataOutputObjectsDelegate) {
        self.outputDelegate = outputDelegate
        super.init(frame:frame)
        initCameraPreview()
        overlay = QrScanOverlay(frame: frame)
        overlay.backgroundColor = UIColor.clear
        addSubview(overlay)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private var device: AVCaptureDevice? {
        return AVCaptureDevice.default(for: .video)
    }
    
    private var hasTorch: Bool {
        return device?.hasTorch ?? false
    }
    
    func startCamera(){
        if(!session.isRunning){
            session.startRunning()
            overlay.startAnimating()
        }
    }
    
    func stopCamera(){
        if(session.isRunning){
            session.stopRunning()
            overlay.stopAnimating()
        }
        setFlash(flash: false)
    }
    
    func setFlash(flash:Bool){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15){
            if let device = self.device {
                guard device.hasFlash && device.hasTorch else {
                    return
                }
                
                do {
                    try device.lockForConfiguration()
                } catch {
                    return
                }
                
                device.flashMode = flash ? .on : .off
                device.torchMode = flash ? .on : .off
                
                device.unlockForConfiguration()
            }
        }
    }
    
    func getFlash() -> Bool {
        return device != nil && (device?.flashMode == AVCaptureDevice.FlashMode.on || device?.torchMode == .on)
    }
    
    func toggleFlash(){
        setFlash(flash: !getFlash())
    }
    
    override func layoutSubviews() {
        previewLayer.frame = frame
        overlay.frame = frame
        self.overlay.startAnimating()
        super.layoutSubviews()
    }
    
    func initCameraPreview() {
        session = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (session.canAddInput(videoInput)) {
            session.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (session.canAddOutput(metadataOutput)) {
            session.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(outputDelegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = CGRect(origin: CGPoint(x:0,y:0), size: CGSize(width: 100, height: 100))
        previewLayer.videoGravity = .resizeAspectFill
        layer.insertSublayer(previewLayer, at: 0)
        self.session.startRunning()
    }
}
