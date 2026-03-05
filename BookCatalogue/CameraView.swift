//
//  CameraView.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/2/26.
//

import UIKit
import AVFoundation

class CameraView: UIViewController {
    var previewView = UIView()
    var captureSession = AVCaptureSession()
    var videoPreviewLayer = AVCaptureVideoPreviewLayer()
//    var input = AVCaptureDeviceInput
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession.addInput(input)
        } catch {
            print(error)
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        previewView.layer.addSublayer(videoPreviewLayer)
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
        
    }
    
//    func loadView() {
//        let
//    }
    
}
