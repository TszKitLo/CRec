//
//  RecordViewController.swift
//  CR
//
//  Created by Keith Lo on 2/1/2017.
//  Copyright © 2017 lotszkitkeith. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import AVKit
import AVFoundation

class RecordViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    var savedFileName1 = "carRec1.mp4"
    let session = AVCaptureSession()
//    let videoCaptureOutput = AVCaptureFileOutput()
    let videoCaptureOutput = AVCaptureMovieFileOutput()
    let fm = FileManager()
    var savePath = NSTemporaryDirectory()
    
    @IBOutlet var frameForCapture: UIView!
    @IBOutlet var recordButton: UIButton!
    
    @IBAction func recordButtonFcn(_ sender: Any) {
        if videoCaptureOutput.isRecording {
            videoCaptureOutput.stopRecording()
            
            
            recordButton.titleLabel?.text = "Start Recording"
        } else {
            savePath = savePath + savedFileName1
            print(savePath)
            videoCaptureOutput.startRecording(toOutputFileURL: NSURL(fileURLWithPath: savePath) as URL!, recordingDelegate: self)
            print("pass")
            recordButton.titleLabel?.text = "Stop Recording"
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        sessionSetup()
        
    }
    
    func sessionSetup(){
        
        session.sessionPreset = AVCaptureSessionPresetMedium
        
        let inputDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        let deviceInput: AVCaptureInput?
        
        // Find input device
        do {
            deviceInput = try AVCaptureDeviceInput(device: inputDevice)
            

        } catch {
            deviceInput = nil
            print("Fail to initialize AVCaptureDeviceInput")
            
        }
        
        if deviceInput != nil {
            // Set input
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            
            // Set output
            videoCaptureOutput.maxRecordedDuration = CMTime(seconds: 120, preferredTimescale: 1)
            
            
            if session.canAddOutput(videoCaptureOutput){
                session.addOutput(videoCaptureOutput)
                
                // Set layout
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                
                previewLayer?.frame = self.frameForCapture.bounds
//                previewLayer?.bounds = self.frameForCapture.layer.bounds
//                previewLayer?.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidT(bounds))
                self.view.layer.addSublayer(previewLayer!)
                
                print("session before start")
                session.startRunning()
                print("session after startRunning()")
            }

        }
        
    }
    
    // MARK: AVCaptureFileOutputRecordingDelegate
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        print("Got a video")
        print(outputFileURL)
        if let pickedVideo:NSURL = (outputFileURL as? NSURL) {
//            // Save video to the main photo album
//            var newPickedVideo = pickedVideo.deletingLastPathComponent
//            newPickedVideo = newPickedVideo?.appendingPathComponent(savedFileName1)
            
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum((outputFileURL.path)){
//                let selectorToCall = #selector(RecordViewController.videoWasSavedSuccessfully(_:didFinishSavingWithError:context:))
//                UISaveVideoAtPathToSavedPhotosAlbum(pickedVideo.relativePath!, self, nil, nil)
                UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, self, nil, nil)
                print("saved to photo album")
            }
            

            
//            // Save the video to the app directory so we can play it later
//            let videoData = NSData(contentsOf: pickedVideo as URL)
////            let paths = NSSearchPathForDirectoriesInDomains(
////                NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
//            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//            let dataPath = path + savedFileName1
//            videoData?.write(toFile: dataPath, atomically: false)
            
        }
        
//        let err: AnyObject
//        do{
//            err = try fm.removeItem(atPath: savePath) as AnyObject
//        } catch {
//            print("Fail to remove file")
//        }
        
    }


}

//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    func captureSessionSetup(){
//        let captureSession = AVCaptureSession()
//        captureSession.sessionPreset = AVCaptureSessionPresetLow
//        let devices = AVCaptureDevice.devices()
//        // Search all devices in devices array
//        if devices != nil {
//            for device in devices! {
//                if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)) {
//                    if ((device as AnyObject).position == AVCaptureDevicePosition.back) {
//                        let captureDevice = device as? AVCaptureDevice
//                        if captureDevice != nil {
//                            beginSession(captureDevice: captureDevice!, captureSession: captureSession)
//                        } else {
//                            print("no back camera")
//                        }
//                    }
//                }
//            }
//        }
//
//
//    }
//
//    func beginSession(captureDevice: AVCaptureDevice, captureSession: AVCaptureSession) {
//        var err : NSError? = nil
//
//        let deviceInput: AVCaptureInput?
//        do {
//            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
//        } catch {
//            deviceInput = nil
//        }
//
//        captureSession.addInput(deviceInput)
//
//        if err != nil {
//            print("Error: \(err?.localizedDescription)")
//        }
//
//        var videoCaptureOutput = AVCaptureFileOutput()
//
//        videoCaptureOutput.maxRecordedDuration = CMTime(seconds: 120, preferredTimescale: 1)
//
//
//
////        videoCaptureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey:kCVPixelFormatType_32BGRA]
////        videoCaptureOutput.alwaysDiscardsLateVideoFrames = true
////
////        captureSession.addOutput(videoCaptureOutput)
////
////        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
////        self.view.layer.addSublayer(previewLayer)
////        previewLayer?.frame = CGRectMake(0, 0, screenWidth, screenHeight)
////        captureSession.startRunning()
////
////        var startVideoBtn = UIButton(frame: CGRectMake(0, screenHeight/2, screenWidth, screenHeight/2))
////        startVideoBtn.addTarget(self, action: "startVideo", forControlEvents: UIControlEvents.TouchUpInside)
////        self.view.addSubview(startVideoBtn)
////
////        var stopVideoBtn = UIButton(frame: CGRectMake(0, 0, screenWidth, screenHeight/2))
////        stopVideoBtn.addTarget(self, action: "stopVideo", forControlEvents: UIControlEvents.TouchUpInside)
////        self.view.addSubview(stopVideoBtn)
//    }
