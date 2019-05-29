//
//  ViewController.swift
//  VideoEditor
//
//  Created by 杨永刚 on 2019/5/27.
//  Copyright © 2019 yyg. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
            }

    @IBAction func reverse(_ sender: Any) {
        let filePath = Bundle.main.path(forResource: "test", ofType: "mp4")
        let savePath = NSTemporaryDirectory() + "video.mp4"
        if VideoReverse.videoReverse(filePath: filePath!, savePath: savePath) {
            
        }

    }
    
}

