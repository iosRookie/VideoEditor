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
        
        VideoReverse.videoReverse(filePath: "", savePath: "")
    }


}

