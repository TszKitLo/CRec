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
import MediaPlayer

class RecordViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, UIImagePickerControllerDelegate {
    var savedFileName1 = "carRec1.mp4"
    var savedFileName2 = "carRec2.mp4"
    let session = AVCaptureSession()
    let videoCaptureOutput = AVCaptureMovieFileOutput()
    let fm = FileManager()
    var savePath = NSTemporaryDirectory()
    
    @IBOutlet var frameForCapture: UIView!
    @IBOutlet var recordButton: UIButton!
    
    @IBAction func recordButtonFcn(_ sender: Any) {
        if videoCaptureOutput.isRecording {
            videoCaptureOutput.stopRecording()
            
            recordButton.setTitle("Record", for: UIControlState.normal)
            
        } else {
            savePath = savePath + savedFileName1
            print(savePath)
            videoCaptureOutput.startRecording(toOutputFileURL: NSURL(fileURLWithPath: savePath) as URL!, recordingDelegate: self)
            recordButton.setTitle("Stop", for: UIControlState.normal)
            
        }
    }

    @IBAction func playbackButtonFcn(_ sender: Any) {
        if videoCaptureOutput.isRecording {
            print("isRecording, stop playback")
        } else {
            print("not recording, playback")
            imagePickerSetup()
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
                
                
                previewLayer?.frame = self.frameForCapture.frame
//                previewLayer?.bounds = self.frameForCapture.layer.bounds
//                previewLayer?.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidT(bounds))
                self.view.layer.addSublayer(previewLayer!)
                
                session.startRunning()
                print("session startRunning()")
            }

        }
        
    }
    
    func imagePickerSetup(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            return
        }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .savedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
        mediaUI.allowsEditing = false
        mediaUI.delegate = self
        
        present(mediaUI, animated: true, completion: nil)
        
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
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        dismiss(animated: true) {
            
            if mediaType == kUTTypeMovie {
                let moviePlayer = MPMoviePlayerViewController(contentURL: (info[UIImagePickerControllerMediaURL] as! NSURL) as URL!)
               
                self.present(moviePlayer!, animated: true, completion: nil)
            }
        }
    }


}

// MARK: UINavigationControllerDelegate

extension RecordViewController: UINavigationControllerDelegate {
}


