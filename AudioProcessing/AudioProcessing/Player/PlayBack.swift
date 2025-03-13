//
//  PlayBack.swift
//  AudioProcessing
//
//  Created by Vishak on 02/03/25.
//

import AVFoundation

class PlayBack {
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let timePitch = AVAudioUnitTimePitch() // For future tempo/pitch adjustments
    private let reverb = AVAudioUnitReverb()
    
    private var audioFile: AVAudioFile?
    private var isPlaying = false
    
    var onPlaybackStateChanged: ((Bool) -> Void)?
    var onTrackDurationChanged: ((Float) -> Void)?
    var onShowToastUntilAudioDownload: ((String, Bool) -> Void)?
    
    init() {
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        audioEngine.attach(playerNode)
        audioEngine.attach(timePitch)
        
        audioEngine.connect(playerNode, to: timePitch, format: nil)
        audioEngine.connect(timePitch, to: audioEngine.mainMixerNode, format: nil)
        
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
    
    func downloadAndLoadTrack(from remoteURL: URL) {
        let localURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_audio2.mp3") // Save as a local file
        onShowToastUntilAudioDownload?("Audio downloading, please wait...", true)
        URLSession.shared.downloadTask(with: remoteURL) { tempURL, _, error in
            if let tempURL = tempURL {
                do {
                    // Move downloaded file to local URL
                    try FileManager.default.moveItem(at: tempURL, to: localURL)
                    
                    DispatchQueue.main.async {
                        self.onShowToastUntilAudioDownload?("", false)
                        self.loadTrack(from: localURL) // Load downloaded file
                    }
                } catch {
                    print("Error saving audio file: \(error)")
                }
            } else if let error = error {
                print("Download error: \(error)")
            }
        }.resume()
    }
    
    func loadTrack(from url: URL) {
        do {
            audioFile = try AVAudioFile(forReading: url)
            if let audioFile = audioFile {
                onTrackDurationChanged?(Float(audioFile.length) / Float(audioFile.processingFormat.sampleRate))
                scheduleAudioFile()
            }
        } catch {
            print("Error loading audio file: \(error)")
        }
    }
    
    
    private func scheduleAudioFile() {
        guard let audioFile = audioFile else { return }
        playerNode.stop()
        playerNode.scheduleFile(audioFile, at: nil)
    }
    
    func playPause() {
        if isPlaying {
            playerNode.pause()
        } else {
            playerNode.play()
        }
        isPlaying.toggle()
        onPlaybackStateChanged?(isPlaying)
    }
    
    func stop() {
        playerNode.stop()
        isPlaying = false
        onPlaybackStateChanged?(isPlaying)
    }
    
    func skipForward10Sec() {
        seek(by: 10)
    }
    
    func skipBackward10Sec() {
        seek(by: -10)
    }
    
    func seek(by seconds: Double) {
        guard let file = audioFile, let lastRenderTime = playerNode.lastRenderTime, let playerTime = playerNode.playerTime(forNodeTime: lastRenderTime) else {
            return
        }
        
        let sampleRate = file.processingFormat.sampleRate
        let currentSample = Double(playerTime.sampleTime)
        let seekSample = max(0, min(currentSample + (seconds * sampleRate), Double(file.length)))
        
        let startTime = AVAudioTime(sampleTime: AVAudioFramePosition(seekSample), atRate: sampleRate)
        playerNode.stop()
        playerNode.scheduleSegment(file, startingFrame: startTime.sampleTime, frameCount: AVAudioFrameCount(file.length - startTime.sampleTime), at: nil)
        if isPlaying {
            playerNode.play()
        }
    }
    
    func seek(to progress: Float) {
        guard let file = audioFile else { return }
        let sampleRate = file.processingFormat.sampleRate
        let seekTime = AVAudioFramePosition(progress * Float(file.length))
        let startTime = AVAudioTime(sampleTime: seekTime, atRate: sampleRate)
        playerNode.stop()
        playerNode.scheduleSegment(file, startingFrame: startTime.sampleTime, frameCount: AVAudioFrameCount(file.length - startTime.sampleTime), at: nil)
        if isPlaying {
            playerNode.play()
        }
    }
}


extension PlayBack {
    
    func getReverbEffect(for effect: String) -> AVAudioUnitReverbPreset {
        switch effect.lowercased() {
        case "hall":
            return .mediumHall
        case "movie":
            return .largeRoom
        case "plate":
            return .plate
        case "cathedral":
            return .cathedral
        case "small room":
            return .smallRoom
        default:
            return .mediumRoom
        }
    }
    
    func setReverbEffect(_ effect: String) {
        reverb.loadFactoryPreset(getReverbEffect(for: effect))
        reverb.wetDryMix = 50
    }
    
    
    func setPlaybackSpeed(_ speed: Float) {
        timePitch.rate = speed
    }
    
    func setPitch(_ pitch: Float) {
        timePitch.pitch = pitch
    }
}
