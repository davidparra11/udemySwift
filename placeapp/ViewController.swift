//
//  ViewController.swift
//  placeapp
//
//  Created by david on 16/05/16.
//  Copyright © 2016 david. All rights reserved.
//

import UIKit
import VideoSplashKit



class ViewController: VideoSplashViewController {
  
    @IBAction func RegisterButton(sender: AnyObject) {
        self.performSegueWithIdentifier("jumpRegister", sender: self)
    }
    @IBAction func LoginButton(sender: AnyObject) {
        self.performSegueWithIdentifier("jumpLogin", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("live", ofType: "mp4")!)
        self.videoFrame = view.frame
        self.fillMode = .ResizeAspectFill
        self.alwaysRepeat = true
        self.sound = false
        self.startTime = 4.0
        self.duration = 18.0
        self.alpha = 0.7
        self.backgroundColor = UIColor.blackColor()
        self.contentURL = url
        self.restartForeground = true
    }
}
