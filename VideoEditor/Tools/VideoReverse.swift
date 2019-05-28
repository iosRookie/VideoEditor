//
//  VideoReverse.swift
//  VideoEditor
//
//  Created by 杨永刚 on 2019/5/28.
//  Copyright © 2019 yyg. All rights reserved.
//

import Foundation
import AVFoundation

func videoReverse(filePath:String, savePath:String) -> Bool {
    let assert = AVAsset.init(url: URL.init(fileURLWithPath: filePath))
    assert.loadValuesAsynchronously(forKeys: ["duration", "tracks"]) {
        print("Assert load finished")
    }
    
    
}
