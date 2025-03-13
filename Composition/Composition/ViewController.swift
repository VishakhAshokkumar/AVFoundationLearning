//
//  ViewController.swift
//  Composition
//
//  Created by Vishak on 25/02/25.
//


import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    private var videoURLs: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    func setUpUI() {
        let selectButton = UIButton(frame: CGRect(x: 50, y: 100, width: 300, height: 50))
        selectButton.setTitle("Select Videos", for: .normal)
        selectButton.backgroundColor = .blue
        selectButton.addTarget(self, action: #selector(selectVideos), for: .touchUpInside)
        
        let mergeButton = UIButton(frame: CGRect(x: 50, y: 200, width: 300, height: 50))
        mergeButton.setTitle("Merge & Export", for: .normal)
        mergeButton.backgroundColor = .red
        mergeButton.addTarget(self, action: #selector(mergeAndExportVideos), for: .touchUpInside)
        
        view.addSubview(selectButton)
        view.addSubview(mergeButton)
    }
    
    @objc
    func selectVideos() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = ["public.movie"]
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @objc
    func mergeAndExportVideos() {
        guard videoURLs.count >= 2 else {
            print("⚠️ Select at least 2 videos to merge.")
            return
        }
        
        mergeVideos(with: videoURLs) { mergedVideoURL in
            if let url = mergedVideoURL {
                print("✅ Merged video saved at: \(url)")
                
                // Apply watermark after merging
                self.applyWatermark(to: url) { watermarkedURL in
                    if let watermarkedVideoURL = watermarkedURL {
                        print("✅ Watermarked video saved at: \(watermarkedVideoURL)")
                        self.saveToPhotoLibrary(videoURL: watermarkedVideoURL)
                    }
                }
            } else {
                print("❌ Failed to merge videos.")
            }
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let mediaUrl = info[.mediaURL] as? URL {
            videoURLs.append(mediaUrl)
            print("📌 Selected video: \(mediaUrl.lastPathComponent)")
        }
        picker.dismiss(animated: true)
    }
}

// MARK: - Video Merging
extension ViewController {
    func mergeVideos(with videoURLs: [URL], completion: @escaping (URL?) -> Void) {
        let composition = AVMutableComposition()
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(nil)
            return
        }
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        var currentTime = CMTime.zero

        for url in videoURLs {
            let asset = AVURLAsset(url: url)
            guard let assetVideoTrack = asset.tracks(withMediaType: .video).first else { continue }
            do {
                try videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: assetVideoTrack, at: currentTime)
                if let assetAudioTrack = asset.tracks(withMediaType: .audio).first {
                    try audioTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: assetAudioTrack, at: currentTime)
                }
                currentTime = CMTimeAdd(currentTime, asset.duration)
            } catch {
                print("❌ Error merging videos: \(error)")
                completion(nil)
                return
            }
        }
        exportComposition(composition: composition, completion: completion)
    }
    
    func exportComposition(composition: AVMutableComposition, completion: @escaping (URL?) -> Void) {
        let outputUrl = FileManager.default.temporaryDirectory.appendingPathComponent("merged_video.mp4")
        if FileManager.default.fileExists(atPath: outputUrl.path) {
            try? FileManager.default.removeItem(at: outputUrl)
        }
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil)
            return
        }
        exportSession.outputURL = outputUrl
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously {
            completion(exportSession.status == .completed ? outputUrl : nil)
        }
    }
}

// MARK: - Apply Watermark
extension ViewController {
    func applyWatermark(to videoUrl: URL, completion: @escaping (URL?) -> Void) {
        let asset = AVURLAsset(url: videoUrl)
        let composition = AVMutableComposition()
        
        guard let videoTrack = asset.tracks(withMediaType: .video).first,
              let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(nil)
            return
        }
        
        try? compositionVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: videoTrack, at: .zero)
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoTrack.naturalSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        // Create Watermark Layer
        let overlayLayer = CATextLayer()
        overlayLayer.string = "My Watermark"
        overlayLayer.fontSize = 40
        overlayLayer.foregroundColor = UIColor.white.cgColor
        overlayLayer.alignmentMode = .center
        overlayLayer.frame = CGRect(x: 50, y: 50, width: 300, height: 100)
        overlayLayer.contentsScale = UIScreen.main.scale
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: videoTrack.naturalSize)
        videoLayer.frame = parentLayer.frame
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)
        
        let animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        videoComposition.animationTool = animationTool
        
        // Export Watermarked Video
        let outputUrl = FileManager.default.temporaryDirectory.appendingPathComponent("watermarked_video.mp4")
        if FileManager.default.fileExists(atPath: outputUrl.path) {
            try? FileManager.default.removeItem(at: outputUrl)
        }
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil)
            return
        }
        
        exportSession.outputURL = outputUrl
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = videoComposition
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously {
            completion(exportSession.status == .completed ? outputUrl : nil)
        }
    }
}

// MARK: - Save to Photo Library
extension ViewController {
    func saveToPhotoLibrary(videoURL: URL) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                let message = success ? "Merged video has been saved to your Photos." : "Failed to save the merged video."
                self.showAlert(title: success ? "Success" : "Error", message: message)
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
