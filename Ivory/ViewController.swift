//
//  ViewController.swift
//  Ivory
//
//  Created by Michael Maloof on 4/10/16.
//  Copyright © 2016 TripTrunk. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    //IBOutlets are done here
    
    //Camera Elements
    @IBOutlet weak var capturePhoto: UIButton!
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var previewView: UIView!
    //Camera Variables
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?

    //IBActions are done here
    @IBAction func captureButtonWasTapped(sender: UIButton) {
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    self.capturedImage.image = image
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundButton()
        
        previewView.hidden = true
        capturedImage.hidden = true
        capturePhoto.hidden = true
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewView.layer.addSublayer(previewLayer!)
                
                captureSession!.startRunning()
                taglineLabel.hidden = true
                previewView.hidden = false
                capturedImage.hidden = false
                capturePhoto.hidden = false
            }
        }
    }
        
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame = previewView.bounds
    }
    
    @IBAction func didPressTakeAnother(sender: AnyObject) {
        captureSession!.startRunning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func roundButton(){
        capturePhoto.backgroundColor = UIColor.clearColor()
        capturePhoto.layer.cornerRadius = 5
        capturePhoto.layer.borderWidth = 1
        capturePhoto.layer.borderColor = UIColor.blackColor().CGColor
    }

}

