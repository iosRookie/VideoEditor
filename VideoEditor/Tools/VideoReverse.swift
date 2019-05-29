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
                timeRange = CMTimeRangeMake(start: startTime, duration: CMTimeSubtract(asset.duration, startTime))
                timeRangeArray.append(timeRange as NSValue)
            }
        }
        
        var tracks = [AVAssetTrack]()
        var assets = [AVAsset]()
        for i in 0..<timeRangeArray.count {
            var subAsset = AVMutableComposition()
            var subTrack = subAsset.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
            do {
                try subTrack.insertTimeRange(timeRangeArray[i] as! CMTimeRange, of: videoTrack, at: startTimeArray[i] as! CMTime)
                let assetNew:AVAsset = subAsset.copy() as! AVAsset
                tracks.append(assetNew.tracks(withMediaType: .video).last!)
                assets.append(assetNew)
            } catch {
                
            }
        }
        
        var totalReader:AVAssetReader = try! AVAssetReader(asset: asset)
        let outputSetting = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        var totalReaderOutput:AVAssetReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSetting)
        if totalReader.canAdd(totalReaderOutput) {
            totalReader.add(totalReaderOutput)
        }
        totalReader.startReading()
        var sampleTimes:Array = [CMSampleBuffer]()
        
        while let totalSample = totalReaderOutput.copyNextSampleBuffer() {
            let presentationTime = CMSampleBufferGetPresentationTimeStamp(totalSample)
//            sampleTimes.append(presentationTime as NSValue)
        
        }
        return true
    }
}

















