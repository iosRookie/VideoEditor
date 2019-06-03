//
//  VideoWriteManager.swift
//  VideoEditor
//
//  Created by yyg on 2019/6/3.
//  Copyright © 2019 yyg. All rights reserved.
//

import Foundation

class VideoWriteManager {
    var wirteToPath:String? = nil
    var writeQueue:DispatchQueue = DispatchQueue(label: "video_data_write_queue")
    
    init(writeToPath: String) {
        self.wirteToPath = writeToPath
    }
}
