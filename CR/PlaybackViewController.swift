//
//  PlaybackViewController.swift
//  CR
//
//  Created by Keith Lo on 2/1/2017.
//  Copyright © 2017 lotszkitkeith. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices

class PlaybackViewController: UIViewController, UIImagePickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePickerSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func imagePickerSetup(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            return
        }
        
        // 2
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .savedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
        mediaUI.allowsEditing = false
        mediaUI.delegate = self
        
        // 3
        present(mediaUI, animated: true, completion: nil)
        
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 1
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        // 2
        dismiss(animated: true) {
            // 3
            if mediaType == kUTTypeMovie {
                let moviePlayer = MPMoviePlayerViewController(contentURL: (info[UIImagePickerControllerMediaURL] as! NSURL) as URL!)
//                self.presentMoviePlayerViewControllerAnimated(moviePlayer)
                self.present(moviePlayer!, animated: true, completion: nil)
            }
        }
    }
    
    

}

// MARK: UINavigationControllerDelegate

extension PlaybackViewController: UINavigationControllerDelegate {
}

