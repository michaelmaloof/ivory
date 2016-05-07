//
//  ViewController.swift
//  Ivory
//
//  Created by Michael Maloof on 4/10/16.
//  Copyright © 2016 TripTrunk. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //IBOutlets are done here
    
    //Camera Elements
    @IBOutlet weak var cameraPreviewView: UIView!
    @IBOutlet weak var capturePhoto: UIButton!
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet var imageTapRecognizer: UITapGestureRecognizer!
    
    //Camera Variables
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCaptureStillImageOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var stillImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        capturedImage.layer.cornerRadius = capturedImage.layer.frame.size.width / 2
        
        toggleCapture(true)
        
        //Click Image To Show ImagePicker
        let imageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.photoImagePressed(_:)))
        capturedImage.userInteractionEnabled = true
        capturedImage.addGestureRecognizer(imageTapGestureRecognizer)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var input: AVCaptureDeviceInput!
        
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error as NSError {
            print(error.debugDescription)
            input = nil
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                cameraPreviewView.layer.addSublayer(previewLayer)
                
                captureSession.startRunning()
                taglineLabel.hidden = true
                toggleCapture(false)
            }
        }
        
    }
        
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let cameraBounds = cameraPreviewView.bounds
        previewLayer.frame = cameraBounds
    }
    
    //IBActions are done here
    @IBAction func captureButtonWasTapped(sender: UIButton) {
        let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
        stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
            if (sampleBuffer != nil) {
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let dataProvider = CGDataProviderCreateWithCFData(imageData)
                let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                
                self.stillImage = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                UIImageWriteToSavedPhotosAlbum(self.stillImage, "image:didFinishSavingWithError:contextInfo:", nil, nil)
                self.capturedImage.image = self.stillImage
                self.performSegueWithIdentifier("showImage", sender: nil)
            }
        })
    }
    
    @IBAction func didPressTakeAnother(sender: AnyObject) {
        captureSession.startRunning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func toggleCapture(state: Bool) {
        capturedImage.hidden = state
        capturePhoto.hidden = state
        cameraPreviewView.hidden = state
    }
    
    func imageTapped(img: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(capturedImage.image!, nil, nil, nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError
        error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed", message: "Failed to save image", preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            
            alert.addAction(cancelAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    func photoImagePressed(gestureRecognizer: UITapGestureRecognizer) {
        let controller = UIImagePickerController()
        controller.delegate = self
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        stillImage = image
        dismissViewControllerAnimated(true) { 
            self.performSegueWithIdentifier("showImage", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImage" {
            let controller = segue.destinationViewController as! PhotoVC
            controller.stillImage = stillImage
        }
    }

}

