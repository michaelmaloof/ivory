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
    
//*********************************
//Stack Changes
//*********************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleCapture(true)
        //set image on the bottom left to show photo library on click
        self.establishPhotoLibraryButton()
        //set up the camera
        self.establishCamera()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.setCameraBounds()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
//*********************************
//Mark Camera & Photo Library
//*********************************

    /**
     The button to capture an image displayed in the camera was tapped
     
     @param sender the capture button
     */
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
    
    /**
    The capture button was pressed again to take another photo (no longer used)
     
     @param sender the capture button
     */
    @IBAction func didPressTakeAnother(sender: AnyObject) {
        captureSession.startRunning()
    }
    
    /**
     Toggle if the app is in a "capture" state (taking a photo)
     
     @param state is capturing or not
     */
    func toggleCapture(state: Bool) {
        capturedImage.hidden = state
        capturePhoto.hidden = state
        cameraPreviewView.hidden = state
    }
    
    /**
    Image was tapped, save the photo (no longer used)
     
     @param img the image tapped
     */
    func imageTapped(img: AnyObject) {
//        UIImageWriteToSavedPhotosAlbum(capturedImage.image!, nil, nil, nil)
    }
    
    /**
     Did image save to camera roll properly
     
     @param image the image saved
     @param didFinishSavinWithError the error
    */
    func image(image: UIImage, didFinishSavingWithError
        error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed", message: "Failed to save image", preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            
            alert.addAction(cancelAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    /**
     PhotoLibrary image was tapped, show photo library
     
     @param gestureRecognizer the gesture recongizer of the image tapped
     */
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
    
//*********************************
//Mark Camera & Photo Set-up
//*********************************
    
    func establishCamera(){
        
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
    
    /**
     Implement the user's photo library and make it selectable
     */
    func establishPhotoLibraryButton(){
        //round the images of the capturedImage button
        capturedImage.layer.cornerRadius = capturedImage.layer.frame.size.width / 2
        //set gesture recognizer to captureImage
        let imageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.photoImagePressed(_:)))
        capturedImage.userInteractionEnabled = true
        capturedImage.addGestureRecognizer(imageTapGestureRecognizer)
    }
    
    /**
    Set the camera's bounds (how its displayed on the screen)
     */
    func setCameraBounds(){
        let cameraBounds = cameraPreviewView.bounds
        previewLayer.frame = cameraBounds
    }
    
}
