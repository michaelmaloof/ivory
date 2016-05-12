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
    @IBOutlet weak var flashStackView: UIStackView!
    @IBOutlet weak var flashOnButton: UIButton!
    @IBOutlet weak var flashOffButton: UIButton!
    @IBOutlet weak var flashAutoButton: UIButton!
    @IBOutlet weak var cameraPreviewView: UIView!
    @IBOutlet weak var capturePhoto: UIButton!
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet var imageTapRecognizer: UITapGestureRecognizer!
    var stillImageView: UIImageView!
    
    //Camera Variables
    let currentDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCaptureStillImageOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var stillImage: UIImage!
    
    var continueButton: UIButton!
    var cancelButton: UIButton!
    
    var switchToFrontCamera = false
    
//*********************************
//Stack
//*********************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleCapture(true)
        //set up cancel and continue button
        self.establishPostCaptureButtons()
        //set image on the bottom left to show photo library on click
        self.establishPhotoLibraryButton()
        //set up the camera
        self.establishCamera()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //set the bounds of the camera
        self.setCameraBounds()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        //hide the status bar to keep the design cleaner
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
        flashStackView.hidden = true
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
                //we have saved the photo to the camera roll, now display it
                self.displayCapturedPhoto()
            }
        })
    }
    
    /**
     Display the captured photo
    */
    func displayCapturedPhoto(){
        self.toggleCapture(true)
        self.stillImageView.image = self.stillImage
        self.stillImageView.hidden = false
        self.continueButton.hidden = false
        self.cancelButton.hidden = false
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
        dismissViewControllerAnimated(true, completion: nil)
        displayCapturedPhoto()
    }
    
    func continueWasTapped() {
    
    }
    
    func cancelWasTapped(){
    self.stillImageView.image = nil;
        self.stillImageView.hidden = true
        self.toggleCapture(false)
        self.continueButton.hidden = true
        self.cancelButton.hidden = true
    }
    
//*********************************
//Mark Camera & Photo Set-up
//*********************************
    
    /**
     Implement the camera
     */
    func establishCamera(){
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        var frontCamera: AVCaptureDevice!
        
        for device in videoDevices{
            let device = device as! AVCaptureDevice
            if device.position == AVCaptureDevicePosition.Front {
                frontCamera = device
                break
            }
        }
        
        var input: AVCaptureDeviceInput!
        
        do {
            if switchToFrontCamera {
                input = try AVCaptureDeviceInput(device: frontCamera)
            } else {
                input = try AVCaptureDeviceInput(device: backCamera)
            }
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
        
        self.establishPreviewImage()
    }
    
    /**
     Switch camera to front or back
     
     - Parameter sender: switch button
     */
    @IBAction func switchButton(sender: AnyObject) {
        if switchToFrontCamera == false {
            switchToFrontCamera = true
        } else {
            switchToFrontCamera = false
        }
        establishCamera()
        setCameraBounds()
    }
    
    //MARK: Flash
    
    /**
     Hides and shows options for flash
     
     - Parameter sender: flash button
     */
    @IBAction func flashButton(sender: AnyObject) {
        if flashStackView.hidden {
            flashStackView.hidden = false
        } else {
            flashStackView.hidden = true
        }
    }
    
    /**
     Toggle flash on, off or auto and sets the label color to show which one is active
     
     - Parameter sender: on, off, and auto buttons
     */
    @IBAction func flashSelection(sender: AnyObject) {
        do {
            try currentDevice.lockForConfiguration()
        } catch {
            print("Can't Lock")
        }
        if sender.tag == 0 {
            flashOnButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            flashOffButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
            flashAutoButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
            currentDevice.flashMode = .On
        } else if sender.tag == 1 {
            flashOnButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
            flashOffButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            flashAutoButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
            currentDevice.flashMode = .Off
        } else if sender.tag == 2 {
            flashOnButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
            flashOffButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
            flashAutoButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            currentDevice.flashMode = .Auto
        }
        currentDevice.unlockForConfiguration()
        flashStackView.hidden = true
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
    
    /**
     Set the imageview for the captured photo
     */
    func establishPreviewImage(){
        self.stillImageView = UIImageView(frame:CGRectMake(self.previewLayer.frame.origin.x, self.previewLayer.frame.origin.y, self.view.frame.width, self.view.frame.height));
        self.stillImageView.hidden = true
        self.stillImageView.contentMode = UIViewContentMode.ScaleAspectFit;
        self.stillImageView.layer
        self.view.insertSubview(self.stillImageView, belowSubview: self.cameraPreviewView)
    }
    
    /**
     Set the continue and cancel buttons
     */
    func establishPostCaptureButtons(){
        
        //continue button
        continueButton = UIButton(type: .System)
        customizePostCaptureButton(continueButton, location: self.view.frame.size.width - 150, title: "Continue", method: #selector(continueWasTapped))

        //cancel button
        cancelButton = UIButton(type: .System)
        customizePostCaptureButton(cancelButton, location: 50, title: "Cancel", method: #selector(cancelWasTapped))
    }
    
    /**
     Customize post capture buttons (continue/cancel)
     
     - Parameter button: the button to set
     - Parameter location: the x-coordinate for the button
     - Parameter title: the title for the button
     - Parameter method: the selector to be called on button press
     */
    func customizePostCaptureButton(button: UIButton, location: CGFloat, title: String, method: Selector) {
        button.frame = CGRectMake(location, self.view.frame.size.height - 75, 100, 50)
        button.backgroundColor = UIColor.darkGrayColor()
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.addTarget(self, action: method, forControlEvents: .TouchUpInside)
        button.layer.cornerRadius = 5.0
        button.hidden = true
        self.view.addSubview(button)
    }
    
//*********************************
//Segues
//*********************************
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
}
