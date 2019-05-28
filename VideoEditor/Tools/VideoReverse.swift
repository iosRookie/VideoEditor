//
//  VideoReverse.swift
//  VideoEditor
//
//  Created by 杨永刚 on 2019/5/28.
//  Copyright © 2019 yyg. All rights reserved.
//

import Foundation
import AVFoundation

class VideoReverse {
    class func videoReverse(filePath:String, savePath:String) -> Bool {
        let asset:AVAsset = AVAsset.init(url: URL.init(fileURLWithPath: filePath))
        asset.loadValuesAsynchronously(forKeys: ["duration", "tracks"]) {
            print("Assert load finished")
        }
        
        var error:NSError
        //获取视频轨道
        let videoTrack = asset.tracks(withMediaType: .video).last!
        var timeRangeArray:Array = [NSValue]()
        var startTimeArray:Array = [NSValue]()
        var startTime:CMTime = .zero
        
        for i in 0...asset.duration.value {
            var timeRange = CMTimeRangeMake(start: startTime, duration: CMTimeMakeWithSeconds(1, preferredTimescale: asset.duration.timescale))
            if CMTimeRangeContainsTimeRange(videoTrack.timeRange, otherRange: timeRange) {
                timeRangeArray.append(timeRange as NSValue)
            } else {
                
            }
        }
        
        
        return true
    }
}

