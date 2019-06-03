//
//  VideoRecordViewController.swift
//  VideoEditor
//
//  Created by yyg on 2019/5/31.
//  Copyright © 2019 yyg. All rights reserved.
//


import UIKit
import AVFoundation

class VideoRecordViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    @IBOutlet weak var videoDisplayView: UIView!
    
    var captureSession:AVCaptureSession? = nil
    
    var captureVideoDeviceInput:AVCaptureDeviceInput? = nil
    var captureStillImageOutput:AVCaptureStillImageOutput? = nil
    
    var captureVideoOutput:AVCaptureVideoDataOutput? = nil
    var videoConnection:AVCaptureConnection? = nil
    
    var captureAudioOutput:AVCaptureAudioDataOutput? = nil
    var audioConnection:AVCaptureConnection? = nil
    
    var captureVideoPreviewLayer:AVCaptureVideoPreviewLayer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCaptureSession()
        self.setupSessionInputs()
        self.setupSessionOutputs()
        
        captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        captureVideoPreviewLayer?.frame = videoDisplayView.layer.bounds
        captureVideoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoDisplayView.layer.addSublayer(captureVideoPreviewLayer!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startCaptureSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.stopCaptureSession()
    }
    
    @IBAction func startReocrding(_ sender: Any) {
        
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        let connection = captureStillImageOutput?.connection(with: .video)
        captureStillImageOutput?.captureStillImageAsynchronously(from: connection!, completionHandler: { (sampleBuffer:CMSampleBuffer?, error:Error?) in
            if  let data:NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer!) as NSData? {
                let savePath = NSSearchPathForDirectoriesInDomains(NSHomeDirectory, NSUserDomainMask, true)[0]
//                data.write(to: , atomically: <#T##Bool#>)
            }
        })
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
}

extension VideoRecordViewController {
    // 开始会话
    func startCaptureSession() {
        if captureSession?.isRunning != true {
            captureSession?.startRunning()
        }
    }
    // 停止会话
    func stopCaptureSession() {
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
    }
    
    // 创建会话
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        if (captureSession?.canSetSessionPreset(.hd1280x720)) == true {
            captureSession?.sessionPreset = .hd1280x720
        } else {
            captureSession?.sessionPreset = .high
        }
    }
    // 设置输入
    func setupSessionInputs() {
        let videoCaptureDevice:AVCaptureDevice = AVCaptureDevice.default(for: .video)!
        captureVideoDeviceInput = try! AVCaptureDeviceInput(device: videoCaptureDevice)
        // 添加视频输入源
        if captureSession?.canAddInput(captureVideoDeviceInput!) == true {
            captureSession?.addInput(captureVideoDeviceInput!)
        }
        
        let audioCaptureDevice:AVCaptureDevice = AVCaptureDevice.default(for: .audio)!
        let captureAudioDeviceInput:AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: audioCaptureDevice)
        if captureSession?.canAddInput(captureAudioDeviceInput) == true {
            captureSession?.addInput(captureAudioDeviceInput)
        }
    }
    //设置输出
    func setupSessionOutputs() {
        let outputQueue = DispatchQueue(label: "capture_data_queue")
        // 视频
        captureVideoOutput = AVCaptureVideoDataOutput()
        captureVideoOutput?.setSampleBufferDelegate(self, queue: outputQueue)
        captureVideoOutput?.alwaysDiscardsLateVideoFrames = true
        captureVideoOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] as [String : Any]
        if captureSession?.canAddOutput(captureVideoOutput!) == true {
            captureSession?.addOutput(captureVideoOutput!)
        }
        videoConnection = captureVideoOutput?.connection(with: .video)
        
        // 音频
        captureAudioOutput = AVCaptureAudioDataOutput()
        captureAudioOutput?.setSampleBufferDelegate(self, queue: outputQueue)
        if captureSession?.canAddOutput(captureAudioOutput!) == true {
            captureSession?.addOutput(captureAudioOutput!)
        }
        audioConnection = captureAudioOutput?.connection(with: .audio)
        
        // 图片
        captureStillImageOutput = AVCaptureStillImageOutput()
        captureStillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        // 添加图片输出源
        if captureSession?.canAddOutput(captureStillImageOutput!) == true {
            captureSession?.addOutput(captureStillImageOutput!)
        }
    }
}

extension VideoRecordViewController {
    func getCameraVideoDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        for i in AVCaptureDevice.devices(for: .video) {
            if i.position == position {
                return i
            }
        }
        return nil
    }
}
