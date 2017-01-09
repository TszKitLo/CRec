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
    let savedFileName1 = "carRec1.mp4"
    let savedFileName2 = "carRec2.mp4"
    let session = AVCaptureSession()
    let videoCaptureOutput = AVCaptureMovieFileOutput()
    let fm = FileManager()
    var recordFlag = false
    
    @IBOutlet var frameForCapture: UIView!
    @IBOutlet var recordButton: UIButton!
    
    @IBAction func recordButtonFcn(_ sender: Any) {
        if recordFlag {   // Stop Recording
            recordButton.setTitle("Record", for: UIControlState.normal)
            recordFlag = false
        } else {    // Start Recording
            recordButton.setTitle("Stop", for: UIControlState.normal)
            recordFlag = true
            recordLoop()
        }
        
        
        
//        if videoCaptureOutput.isRecording {
//            videoCaptureOutput.stopRecording()
//            
//            recordButton.setTitle("Record", for: UIControlState.normal)
//            
//        } else {
//            startRecord()
//
//            recordButton.setTitle("Stop", for: UIControlState.normal)
//            
//        }
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
    
    func startRecord(){
        let savePath = pickSavingPath()

        print(savePath)
        
        if savePath != "" {
            videoCaptureOutput.startRecording(toOutputFileURL: NSURL(fileURLWithPath: savePath) as URL!, recordingDelegate: self)
        }
    }
    
    func pickSavingPath() -> String{
//        let tempPath1 = NSTemporaryDirectory() + savedFileName1
//        let tempPath2 = NSTemporaryDirectory() + savedFileName2
        
        let tempPath1 = fm.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)[0].absoluteString + savedFileName1
        let tempPath2 = fm.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)[0].absoluteString + savedFileName2
        
//        let tempUrl1 = fm.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
//        print(tempUrl1)
//        let x = (tempUrl1 as NSURL).isFileReferenceURL()
//        print(tempUrl1.isFileReferenceURL())
        print(tempPath1)
        print(tempPath2)
        
        if !fm.fileExists(atPath: tempPath1) && !fm.fileExists(atPath: tempPath2){
            print("carRec1.mp4 and carRec2.mp4 do not exist")
            
            return tempPath1
            
        } else if !fm.fileExists(atPath: tempPath1) && fm.fileExists(atPath: tempPath2){
            print("carRec1.mp4 does not exist")
            
            return tempPath1
            
        } else if !fm.fileExists(atPath: tempPath2) && fm.fileExists(atPath: tempPath1){
            print("carRec2.mp4 does not exist")
            
            return tempPath2
        } else {
            print("Both files exist")
            
            let leastUsedFilePath = findLeastUsedFile(tempPath1: tempPath1, tempPath2: tempPath2)
            
            if leastUsedFilePath != "" {
                deleteFile(path: leastUsedFilePath)
            }

            return leastUsedFilePath
        }
 
    }
    
    func deleteFile(path: String){
        
        do{
            try fm.removeItem(atPath: path)
        } catch let err as NSError{
            print("Fail to remove file")
            print(err)
        }
    }
    
    func findLeastUsedFile(tempPath1: String, tempPath2: String) -> String{
        
        do{
            let attributesOfPath1 = try fm.attributesOfItem(atPath: tempPath1) as NSDictionary
            
            do{
                let attributesOfPath2 = try fm.attributesOfItem(atPath: tempPath2) as NSDictionary
                
                let date1 = attributesOfPath1["NSFileCreationDate"] as! NSDate
                let date2 = attributesOfPath2["NSFileCreationDate"] as! NSDate
                
                print("date1")
                print("date2")
                
                
                if date1.compare(date2 as Date) == .orderedAscending{
                    print("date1 is earlier")
                    return tempPath1
                } else {
                    print("date2 is earlier")
                    return tempPath2
                }
                
            } catch let error as NSError{
                print("Fail to read carRec2")
                print(error)
            }
            
        } catch let error as NSError{
            print("Fail to read carRec1")
            print(error)
        }
        
        
        
        

        
        
        return ""
    }
    
    func recordLoop() {
//        while recordFlag {
//            if !videoCaptureOutput.isRecording {
//                startRecord()
//            }
//            
//        }
        startRecord()
        
        videoCaptureOutput.stopRecording()
        
    }
    
    // MARK: AVCaptureFileOutputRecordingDelegate
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        print("Got a video")
        print("outputFileURL \(outputFileURL)")
        print("outFileURL.path \(outputFileURL.path)")
        print("outputFileURL.relativePath \(outputFileURL.relativePath)")
        
        if let pickedVideo:NSURL = (outputFileURL as? NSURL) {
//            let videoData = NSData(contentsOf: pickedVideo as URL)
//            let paths = NSSearchPathForDirectoriesInDomains(
//                FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//            let dataPath = path + savedFileName1
            
//            if fm.fileExists(atPath: pickedVideo.path!) {
//                print("file exist")
//            } else {
//                print("file does not exist")
//            }
            
//            let dataPath = pickedVideo.path
//            videoData?.write(toFile: dataPath!, atomically: false)
            
//            if fm.fileExists(atPath: pickedVideo.relativePath!) {
//                print("file exist")
//            } else {
//                print("file does not exist")
//            }
            
//            let finalPath = NSURL.init(fileURLWithPath: outputFileURL.path)
            

            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputFileURL.path){

                UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, self, nil, nil)
                print("saved to photo album")
            }
        
            
        }
        
        
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


