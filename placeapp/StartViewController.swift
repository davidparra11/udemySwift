//
//  StartViewController.swift
//  placeapp
//
//  Created by david on 10/05/16.
//  Copyright © 2016 david. All rights reserved.
//

import UIKit
import VideoSplashKit

class StartViewController: VideoSplashViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("test", ofType: "mp4")!)
        self.videoFrame = view.frame
        self.fillMode = .ResizeAspectFill
        self.alwaysRepeat = true
        self.sound = true
        self.startTime = 12.0
        self.duration = 15.0
        self.alpha = 0.7
        self.backgroundColor = UIColor.blackColor()
        self.contentURL = url
        self.restartForeground = true
    }
}
    


