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
import Photos

class RecordViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    let savedFileName1 = "carRec1"
    let savedFileName2 = "carRec2"
    let pathExtension = "mp4"
    let session = AVCaptureSession()
    let videoCaptureOutput = AVCaptureMovieFileOutput()
    let fm = FileManager.default
    var recordFlag = false
    
    @IBOutlet var frameForCapture: UIView!
    @IBOutlet var recordButton: UIButton!
    
    @IBAction func recordButtonFcn(_ sender: Any) {
        if recordFlag {   // Stop Recording
            recordButton.setTitle("Record", for: UIControlState.normal)
            recordFlag = false
            videoCaptureOutput.stopRecording()
        } else {    // Start Recording
            recordButton.setTitle("Stop", for: UIControlState.normal)
            recordFlag = true
            recordLoop()
        }
        
    }
    
    @IBAction func playbackButtonFcn(_ sender: Any) {
        if videoCaptureOutput.isRecording {
            print("isRecording, stop playback")
        } else {
            print("not recording, playback")
            videoPickerSetup()
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
    
    func videoPickerSetup(){
//        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
//            return
//        }
//        
//        let mediaUI = UIImagePickerController()
//        mediaUI.sourceType = .savedPhotosAlbum
//        mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
//        mediaUI.allowsEditing = false
//        mediaUI.delegate = self
//        
//        present(mediaUI, animated: true, completion: nil)
        
        videoPickerSheet()
        
        
    }
    
    func videoPickerSheet() {
        let paths = createTempPaths()
        let tempPath1 = paths[0]
        let tempPath2 = paths[1]
        
        if checkFilesExist(tempPath1: tempPath1, tempPath2: tempPath2) == 1 {
            let picker = UIAlertController.init(title: "No Video", message: nil, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "Cancel", style: .cancel, handler: {
                (action:UIAlertAction!) -> Void in
                picker.dismiss(animated: true, completion: nil)
            })
            picker.addAction(action)

        } else if checkFilesExist(tempPath1: tempPath1, tempPath2: tempPath2) == 2 {
            self.playVideo(url: tempPath2)
        } else if checkFilesExist(tempPath1: tempPath1, tempPath2: tempPath2) == 3 {
            self.playVideo(url: tempPath1)
        } else {
            let leastRecentlyUsedPath = findLeastUsedFile(tempPath1: tempPath1, tempPath2: tempPath2)
            var mostRecentlyUsedePath = tempPath1
            if leastRecentlyUsedPath == tempPath1 {
                mostRecentlyUsedePath = tempPath2
            }
            
            let picker = UIAlertController.init(title: "Select Video", message: nil, preferredStyle: .actionSheet)
            
            let latestVideo = UIAlertAction.init(title: "Latest Video", style: .default, handler: {
                (action:UIAlertAction!) -> Void in
                self.playVideo(url: mostRecentlyUsedePath)
                picker.dismiss(animated: false, completion: nil)
            })
            
            let olderVideo = UIAlertAction.init(title: "Older Video", style: .default, handler: {
                (action:UIAlertAction!) -> Void in
                self.playVideo(url: leastRecentlyUsedPath!)
                picker.dismiss(animated: false, completion: nil)
            })
            
            let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: {
                (action:UIAlertAction!) -> Void in
                picker.dismiss(animated: true, completion: nil)
            })
            
            picker.addAction(latestVideo)
            picker.addAction(olderVideo)
            picker.addAction(cancel)
            
            
            present(picker, animated: true, completion: nil)
        }

    }
    
    func playVideo(url: NSURL) {
        print("start video player")
        print("file will be played = \(url)")
        
        //let player = AVPlayer(url: url as URL)
        //let playerLayer = AVPlayerLayer(player: player)
        //playerLayer.frame = self.view.bounds
        //self.view.layer.addSublayer(playerLayer)
        //player.play()
        
        
        let player = AVPlayer(url: url as URL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func startRecord(){
        let savePath = pickSavingPath()
        
        print("savePath = \(savePath)")
        
        
        videoCaptureOutput.startRecording(toOutputFileURL: savePath as URL!, recordingDelegate: self)
        
    }
    
    func createTempPaths() -> [NSURL]{
        let tempPath1: NSURL = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(savedFileName1).appendingPathExtension(pathExtension) as NSURL
        let tempPath2: NSURL = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(savedFileName2).appendingPathExtension(pathExtension) as NSURL
        let paths: [NSURL] = [tempPath1,tempPath2]
        return paths
    }
    
    func pickSavingPath() -> NSURL{
        
        let paths = createTempPaths()
        let tempPath1 = paths[0]
        let tempPath2 = paths[1]
        
//        let tempPath1: NSURL = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(savedFileName1).appendingPathExtension(pathExtension) as NSURL
//        let tempPath2: NSURL = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(savedFileName2).appendingPathExtension(pathExtension) as NSURL
        
        //        let tempPath1: NSURL = NSURL.fileURL(withPath: savedFileName1, isDirectory: false) as NSURL
        //        let tempPath2: NSURL = NSURL.fileURL(withPath: savedFileName1, isDirectory: false) as NSURL
        //
        //        tempPath1.appendingPathExtension(pathExtension)
        //        tempPath2.appendingPathExtension(pathExtension)
        //
        
        
        //        let tempPath1 = NSURL.init(string: savedFileName1 + pathExtension)! as NSURL
        //        let tempPath2 = NSURL.init(string: savedFileName2 + pathExtension)! as NSURL
        //
        //                print("new path1 = \(tempPath1)")
        //                print("new path2 = \(tempPath2)")
        

        
//        print(NSHomeDirectory())
//        
//        print("tempPath1 = \(tempPath1)")
//        print("tempPath2 = \(tempPath2)")
//        
//        print("tempPath1.absoluteURL = \(tempPath1.absoluteURL)")
//        print("tempPath2.absoluteURL = \(tempPath2.absoluteURL)")
//        
//        print("tempPath1.extension = \(tempPath1.pathExtension)")
//        print("tempPath2.extension = \(tempPath2.pathExtension)")
//        
//        print("tempPath1.pathComponent = \(tempPath1.pathComponents)")
//        print("tempPath2.pathComponent = \(tempPath2.pathComponents)")
//        
//        print("tempPath1.path = \(tempPath1.path)")
//        print("tempPath2.path = \(tempPath2.path)")
//        
//        print("tempPath1.relativePath = \(tempPath1.relativePath)")
//        print("tempPath2.relativePath = \(tempPath2.relativePath)")
        
        if checkFilesExist(tempPath1: tempPath1, tempPath2: tempPath2) == 1{
            
            
            return tempPath1 as NSURL
            
        } else if checkFilesExist(tempPath1: tempPath1, tempPath2: tempPath2) == 2{
            
            
            return tempPath1 as NSURL
            
        } else if checkFilesExist(tempPath1: tempPath1, tempPath2: tempPath2) == 3{
           
            
            return tempPath2 as NSURL
        } else {
            
            
            let leastUsedFilePath = findLeastUsedFile(tempPath1: tempPath1, tempPath2: tempPath2)
            
            if leastUsedFilePath != nil {
                deleteFile(url: leastUsedFilePath!)
            }
            
            if leastUsedFilePath == tempPath1 {
                return tempPath1 as NSURL
            } else {
                return tempPath2 as NSURL
            }
        }
        
    }
    
    func checkFilesExist(tempPath1: NSURL, tempPath2: NSURL) -> Int {
        if !fm.fileExists(atPath: tempPath1.relativePath!) && !fm.fileExists(atPath: tempPath2.relativePath!){
            print("carRec1.mp4 and carRec2.mp4 do not exist")
            
            return 1
            
        } else if !fm.fileExists(atPath: tempPath1.relativePath!) && fm.fileExists(atPath: tempPath2.relativePath!){
            print("carRec1.mp4 does not exist")
            
            return 2
            
        } else if !fm.fileExists(atPath: tempPath2.relativePath!) && fm.fileExists(atPath: tempPath1.relativePath!){
            print("carRec2.mp4 does not exist")
            
            return 3
        } else {
            print("Both files exist")
            
            return 4
        }
    }
    
    func deleteFile(url: NSURL){
//        // Delete video from photo album
//        let urls: [URL] = [url as URL]
//        print("urls = \(urls)")
//        PHPhotoLibrary.shared().performChanges({
//            let assestToDelete = PHAsset.fetchAssets(withALAssetURLs: urls, options: nil)
//            print("fetch result = \(assestToDelete)")
//            PHAssetChangeRequest.deleteAssets(assestToDelete)
//        }, completionHandler: nil)
        
        // Delete video from app folder
        var result: AnyObject
        do{
            result = try fm.removeItem(atPath: url.relativePath!) as AnyObject
            if fm.fileExists(atPath: url.relativePath!) {
                print("file still exist")
            } else {
                print("file is deleted")
            }
        } catch let error as NSError{
            print("Fail to remove file")
            print(error)
        }
        
//        do {
//            let x = try fm.contentsOfDirectory(atPath: fm.urls(for: .documentDirectory, in: .userDomainMask)[0].path)
//            print("remaining file in \(x)")
//            for y in x {
//                print(y)
//            }
//        } catch let err as NSError {
//            print(err)
//        }
        
    }
    
    func findLeastUsedFile(tempPath1: NSURL, tempPath2: NSURL) -> NSURL?{
        
        do{
            let attributesOfPath1 = try fm.attributesOfItem(atPath: tempPath1.path!) as NSDictionary
            
            do{
                let attributesOfPath2 = try fm.attributesOfItem(atPath: tempPath2.path!) as NSDictionary
                
                let date1 = attributesOfPath1["NSFileCreationDate"] as! NSDate
                let date2 = attributesOfPath2["NSFileCreationDate"] as! NSDate
                
                print("date1 = \(date1)")
                print("date2 = \(date2)")
                
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
        
        
        
        
        
        
        return nil
        
    }
    
    func recordLoop() {
        //        while recordFlag {
        //            print("outside if")
        //            if !videoCaptureOutput.isRecording {
        //                print("in if")
        //                startRecord()
        //            }
        //
        //        }
        startRecord()
        
        //        videoCaptureOutput.stopRecording()
        
        
        
    }
    
    // MARK: AVCaptureFileOutputRecordingDelegate
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        print("Got a video")
        
//        if let pickedVideo:NSURL = (outputFileURL as? NSURL) {
//            
//            
//            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pickedVideo.relativePath!){
//                
//                UISaveVideoAtPathToSavedPhotosAlbum(pickedVideo.relativePath!, self, nil, nil)
//                print("saved to photo album")
//            }
//            
//            
//        }
        
        
        
        
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("Recording did start")
    }
    
//    // MARK: UIImagePickerControllerDelegate
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        
//        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
//        
//        dismiss(animated: true) {
//            
//            if mediaType == kUTTypeMovie {
//                let moviePlayer = MPMoviePlayerViewController(contentURL: (info[UIImagePickerControllerMediaURL] as! NSURL) as URL!)
//                
//                self.present(moviePlayer!, animated: true, completion: nil)
//            }
//        }
//    }
    
    
}

// MARK: UINavigationControllerDelegate

extension RecordViewController: UINavigationControllerDelegate {
}


