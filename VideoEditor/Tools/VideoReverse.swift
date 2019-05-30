//
//  VideoReverse.swift
//  VideoEditor
//
//  Created by 杨永刚 on 2019/5/28.
//  Copyright © 2019 yyg. All rights reserved.
//

import Foundation
import AVFoundation

class VideoReverse: NSObject {
     func videoReverse(filePath:String, savePath:String) -> Bool {
        let asset:AVAsset = AVAsset.init(url: URL.init(fileURLWithPath: filePath))
        asset.loadValuesAsynchronously(forKeys: ["duration", "tracks"]) {
            var error:NSError? = nil
            let dStatus = asset.statusOfValue(forKey: "duration", error: &error)
            switch dStatus {
            case .unknown:
                print("duration load unknown")
            case .loading:
                print("duration load loading")
            case .loaded:
                print("duration load loaded")
            case .failed:
                print("duration load failed")
            case .cancelled:
                print("duration load cancelled")
            }
            if dStatus != .loaded {
                print("duration load failed")
            }
            
            let tStatus = asset.statusOfValue(forKey: "tracks", error: &error)
            if tStatus != .loaded {
                print("duration load failed")
            }
            
            //获取视频轨道
            let videoTrack:AVAssetTrack = asset.tracks(withMediaType: .video).last!
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
            for i in 0 ..< timeRangeArray.count {
                let subAsset = AVMutableComposition()
                let subTrack:AVMutableCompositionTrack = subAsset.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
                do {
                    try subTrack.insertTimeRange(timeRangeArray[i] as! CMTimeRange, of: videoTrack, at: startTimeArray[i] as! CMTime)
                    let assetNew:AVAsset = subAsset.copy() as! AVAsset
                    tracks.append(assetNew.tracks(withMediaType: .video).last!)
                    assets.append(assetNew)
                } catch {
                    
                }
            }
            
            let totalRenderOutputSetting = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
            let totalReaderOutput:AVAssetReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: totalRenderOutputSetting)
            let totalReader:AVAssetReader = try! AVAssetReader(asset: asset)
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
            for i in stride(from: tracks.count-1, through: 0, by: -1) {
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
                    let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffers[index])!
                    if !pixelBufferAdapter.append(pixelBuffer, withPresentationTime: tmPTime) {
                        print("添加pixelBuffer失败")
                    } else {
                        print("添加pixelBuffer成功")
                    }
                    counter += 1;
                }
            }
            writer.finishWriting {
                print("写入完成")
            }
        }
        
        return true
    }
}


















