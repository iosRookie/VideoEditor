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
            var error:NSError? = nil
            let dStatus = asset.statusOfValue(forKey: "duration", error: &error)
            
            let tStatus = asset.statusOfValue(forKey: "tracks", error: &error)
            
            //获取视频轨道
            let videoTrack = asset.tracks(withMediaType: .video).last!
            var timeRangeArray:Array = [NSValue]()
            var startTimeArray:Array = [NSValue]()
            var startTime:CMTime = .zero
            
            for _ in stride(from: 0, through: CMTimeGetSeconds(asset.duration), by: 1) {
                var timeRange = CMTimeRangeMake(start: startTime, duration: CMTimeMakeWithSeconds(1, preferredTimescale: asset.duration.timescale))
                if CMTimeRangeContainsTimeRange(videoTrack.timeRange, otherRange: timeRange) {
                    timeRangeArray.append(timeRange as NSValue)
                } else {
                    timeRange = CMTimeRangeMake(start: startTime, duration: CMTimeSubtract(asset.duration, startTime))
                    timeRangeArray.append(timeRange as NSValue)
                }
                startTimeArray.append(startTime as NSValue)
                startTime = CMTimeAdd(timeRange.start, timeRange.duration)
            }
            
            var tracks:Array = [AVAssetTrack]()
            var assets:Array = [AVAsset]()
            for i in 0..<timeRangeArray.count {
                let subAsset = AVMutableComposition()
                let subTrack = subAsset.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
                do {
                    try subTrack.insertTimeRange(timeRangeArray[i] as! CMTimeRange, of: videoTrack, at: startTimeArray[i] as! CMTime)
                    let assetNew:AVAsset = subAsset.copy() as! AVAsset
                    tracks.append(assetNew.tracks(withMediaType: .video).last!)
                    assets.append(assetNew)
                } catch {
                    
                }
            }
            
            let totalReader:AVAssetReader = try! AVAssetReader(asset: asset)
            let totalRenderOutputSetting = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
            let totalReaderOutput:AVAssetReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: totalRenderOutputSetting)
            if totalReader.canAdd(totalReaderOutput) {
                totalReader.add(totalReaderOutput)
            }
            totalReader.startReading()
            var sampleTimes:Array = [NSValue]()
            
            while let totalSample = totalReaderOutput.copyNextSampleBuffer() {
                let presentationTime = CMSampleBufferGetPresentationTimeStamp(totalSample)
                sampleTimes.append(presentationTime as NSValue)
            }
            
            let writer:AVAssetWriter = try! AVAssetWriter(outputURL: URL(fileURLWithPath: savePath), fileType: .mp4)
            let videoCompressionProps = [AVVideoAverageBitRateKey:videoTrack.estimatedDataRate];
            let width = videoTrack.naturalSize.width
            let height = videoTrack.naturalSize.height
            let writerOutputSetting = [AVVideoCodecKey:AVVideoCodecH264, AVVideoHeightKey:height as NSValue, AVVideoWidthKey:width as NSValue, AVVideoCompressionPropertiesKey:videoCompressionProps] as [String : Any];
            let writerInput:AVAssetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: writerOutputSetting, sourceFormatHint: (videoTrack.formatDescriptions.last as! CMFormatDescription))
            writerInput.expectsMediaDataInRealTime = false
            let pixelBufferAdapter:AVAssetWriterInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: nil)
            writer.add(writerInput)
            
            writer.startWriting()
            writer.startSession(atSourceTime: videoTrack.timeRange.start)
            
            var counter = 0
            //        var totalCountOfArray = 40
            //        var arrayIncreamsment = 40
            for i in stride(from: tracks.count-1, through: 0, by: -1) {
                //            [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:tracks[i] outputSettings:totalReaderOutputSettings];
                let reader:AVAssetReader = try! AVAssetReader(asset: assets[i])
                let readerOutput:AVAssetReaderTrackOutput = AVAssetReaderTrackOutput(track: tracks[i], outputSettings: totalRenderOutputSetting)
                if reader.canAdd(readerOutput) {
                    reader.add(readerOutput)
                }
                
                reader.startReading()
                
                var countOfFrames:Int = 0
                var sampleBuffers:Array = [CMSampleBuffer]()
                while let sampleBuffer = readerOutput.copyNextSampleBuffer() {
                    let tmPresentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                    if CMTimeCompare(tmPresentationTime, startTimeArray[i] as! CMTime) >= 0 {
                        sampleBuffers.append(sampleBuffer)
                        countOfFrames += 1;
                    }
                }
                reader.cancelReading()
                
                for j in stride(from: 0, to: countOfFrames, by: 1) {
                    if counter > sampleTimes.count - 1 {
                        break
                    }
                    let tmPTime:CMTime = sampleTimes[counter] as! CMTime
                    while !writerInput.isReadyForMoreMediaData {
                        Thread.sleep(forTimeInterval: 0.1)
                    }
                    let index = countOfFrames - j - 1
                    
                    pixelBufferAdapter.append(CMSampleBufferGetImageBuffer(sampleBuffers[index])!, withPresentationTime: tmPTime)
                    counter += 1;
                }
                
                writer.finishWriting {
                    
                }
            }
        }
        
        return true
    }
}


















