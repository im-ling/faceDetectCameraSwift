//
//  AVCaptureVideoPicViewController.swift
//  myCameraDemo
//
//  Created by NowOrNever on 17/07/2017.
//  Copyright © 2017 Focus. All rights reserved.
//

import UIKit
import AVFoundation

class AVCaptureVideoPicViewController: UIViewController ,AVCaptureVideoDataOutputSampleBufferDelegate{
    
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var overlayView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
//    左上角小的预览图
//    var smallPicture:UIImageView = {
//        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 144, height: 192))
//        return imageView
//    }()
    

    var isStart = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: setupUI
    
    fileprivate func setupUI(){
        print("setupUI")
        self.view.backgroundColor = UIColor.blue
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices:[AVCaptureDevice] = AVCaptureDevice.devices()! as! [AVCaptureDevice]
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)){
                if (device.position == AVCaptureDevicePosition.front){
                    captureDevice = device
                    if captureDevice != nil{
                        print("Capture Device found")
                        beginSession()
                    }
                }
            }
        }

        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(isStartTrue), userInfo: nil, repeats: false)
        
        self.view.addSubview(overlayView)
        overlayView.frame = self.view.frame

//        self.view.addSubview(smallPicture)
        
    }

    
    @objc func isStartTrue() -> () {
        isStart = true
    }

    private func beginSession(){
        print("beginSession")

        try! captureSession.addInput(AVCaptureDeviceInput.init(device: captureDevice!))
        let output = AVCaptureVideoDataOutput()
        
        let cameraQueue = DispatchQueue.init(label: "cameraQueue")
        output.setSampleBufferDelegate(self, queue: cameraQueue)
        //MARK: PROBLEM
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA];
        captureSession.addOutput(output)
        
        
        previewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect;
        previewLayer?.frame = self.view.bounds;
        self.view.layer.addSublayer(previewLayer!)
        
        captureSession.startRunning()
        
    }
    
    func captureOutput(_ output: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        //        print("captureOutput")
        if(self.isStart)
        {
            var resultImage = sampleBufferToImage(sampleBuffer: sampleBuffer)
            resultImage = resultImage.fixedOrientation()
            print(resultImage.size)
            
            let scale:CGFloat = UIScreen.main.bounds.width / resultImage.size.width;
            let topMargin = (UIScreen.main.bounds.height - resultImage.size.height * scale) * 0.5
            
            
            let context = CIContext(options:[kCIContextUseSoftwareRenderer:true])
            let detecotr = CIDetector(ofType:CIDetectorTypeFace,  context:context, options:[CIDetectorAccuracy: CIDetectorAccuracyHigh,CIDetectorMinFeatureSize:NSNumber.init(value: 0.2)])
            
            let ciImage = CIImage(image: resultImage)!
            let results = detecotr?.features(in: ciImage, options: [CIDetectorImageOrientation:NSNumber.init(value: 1)])
            
            DispatchQueue.main.async {
                //                print("put result image")
                //                self.smallPreView.image = resultImage
                if self.overlayView.layer.sublayers != nil{
                    for item in self.overlayView.layer.sublayers!{
                        item.removeFromSuperlayer()
                    }
                }
            }
            
            
            
            for r in results! {
                let face:CIFaceFeature = r as! CIFaceFeature;
                print(face.bounds)
                let facelayer = CALayer.init()
                facelayer.borderColor = UIColor.red.cgColor
                facelayer.borderWidth = 2
                
                
                //                smallLayer.frame = face.bounds
                //                smallLayer.frame = CGRect.init(x: face.bounds.origin.y, y: face.bounds.origin.x, width: face.bounds.size.width, height: face.bounds.size.height)
                
                facelayer.frame = CGRect.init(x:face.bounds.origin.x * scale, y:topMargin + (resultImage.size.height - face.bounds.origin.y - face.bounds.size.height ) * scale, width: face.bounds.size.width * scale, height: face.bounds.size.height * scale)
                
                let markWidth:CGFloat = 5.0
                
                let mouthLayer = CALayer.init()
                mouthLayer.borderColor = UIColor.red.cgColor
                mouthLayer.borderWidth = 2
                mouthLayer.frame = CGRect.init(x:face.mouthPosition.x * scale - markWidth , y: topMargin + (resultImage.size.height - face.mouthPosition.y) * scale - markWidth, width: markWidth * 2, height: markWidth * 2)
                
                
                DispatchQueue.main.async {
                    self.overlayView.layer.addSublayer(facelayer)
                    self.overlayView.layer.addSublayer(mouthLayer)
                }
            }
        }
    }
    
    
    private func sampleBufferToImage(sampleBuffer: CMSampleBuffer!) -> UIImage {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!;
        let ciImage = CIImage.init(cvPixelBuffer: imageBuffer);
        let temporaryContext = CIContext.init()
        let videoImage = temporaryContext.createCGImage(ciImage, from: CGRect.init(x: 0, y: 0, width: CVPixelBufferGetWidth(imageBuffer), height: CVPixelBufferGetHeight(imageBuffer)))!
        let resultImage = UIImage.init(cgImage: videoImage, scale: 1.0, orientation: UIImageOrientation.leftMirrored);
        return resultImage;
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        captureSession.stopRunning()
    }
}
