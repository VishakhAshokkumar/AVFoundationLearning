//
//  ViewController.swift
//  AudioProcessing
//
//  Created by Vishak on 27/02/25.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    private let player = PlayerViewModel()
    private let playerView = PlayerView()
    private let playBackView = PlayBackView()
    private let playback = PlayBack() // Instance of PlayBack
    private let audioFeatureView = AudioFeatureCollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearTemporaryDirectory()
        setupUI()
        bindUI()
        fetchTracks()
    }
    
    private func fetchTracks() {
        player.fetchTracks()
    }
    
    private func bindUI() {
        player.onTracksFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
        
        playback.onPlaybackStateChanged = { [weak self] isPlaying in
            DispatchQueue.main.async {
                self?.playBackView.updatePlayPauseButton(isPlaying: isPlaying)
            }
        }
        
        playback.onShowToastUntilAudioDownload = { [weak self] message, show in
            DispatchQueue.main.async {
                if show {
                    self?.showToast(message: message)
                } else {
                    self?.dismissToast()
                }
            }
            
        }
    }
    
    private func updateUI() {
        guard let firstTrack = player.tracks.randomElement() else { return }
        playerView.configure(from: firstTrack)
        
        if let trackURL = firstTrack.audioURL { // Ensure you have a URL
            playback.downloadAndLoadTrack(from: trackURL)
        }
        
        showPlayBackView()
    }
}

private extension PlayerViewController {
    
    func setupUI() {
        view.backgroundColor = .black
        addPlayerView()
        addPlaybackView()
        setupPlaybackActions()
        addAudioFeatureView()
    }
    
    func addPlayerView() {
        view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            playerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
    }
    
    func addPlaybackView() {
        view.addSubview(playBackView)
        playBackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playBackView.topAnchor.constraint(equalTo: playerView.bottomAnchor, constant: 20),
            playBackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            playBackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            playBackView.heightAnchor.constraint(equalToConstant: 100)
        ])
        playBackView.isHidden = true
    }
    
    private func addAudioFeatureView() {
        view.addSubview(audioFeatureView)
        audioFeatureView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioFeatureView.topAnchor.constraint(equalTo: playBackView.bottomAnchor, constant: 20),
            audioFeatureView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            audioFeatureView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            audioFeatureView.heightAnchor.constraint(equalToConstant: 140)
        ])
        
        audioFeatureView.delegate = self
    }
    
    func showPlayBackView() {
        UIView.animate(withDuration: 0.3) {
            self.playBackView.isHidden = false
            self.playBackView.alpha = 1.0
        }
    }
    
    func setupPlaybackActions() {
        playBackView.onPlayPauseTapped = { [weak self] in
            self?.playback.playPause()
        }
    }
}



extension PlayerViewController {
    func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        let toastHeight: CGFloat = 40
        let toastWidth: CGFloat = self.view.frame.width * 0.8
        toastLabel.frame = CGRect(
            x: (self.view.frame.width - toastWidth) / 2,
            y: self.view.frame.height - toastHeight - 80,
            width: toastWidth,
            height: toastHeight
        )
        
        view.addSubview(toastLabel)
        toastLabel.tag = 999 // Use tag to find and remove later
    }
    
    func dismissToast() {
        if let toastLabel = view.viewWithTag(999) {
            UIView.animate(withDuration: 0.5, animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
}


extension PlayerViewController: AudioFeatureCollectionViewDelegate {
    func didChangePlaybackSpeed(to speed: Float) {
        playback.setPlaybackSpeed(speed)
    }
    
    func didChangeReverbEffect(to effect: String) {
        playback.setReverbEffect(effect)
    }
    
    func didChangePitch(to pitch: Float) {
        playback.setPitch(pitch)
    }
    
    
    func clearTemporaryDirectory() {
        let tempDirectory = FileManager.default.temporaryDirectory
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil, options: [])
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
            print("Temporary directory cleared successfully.")
        } catch {
            print("Error clearing temporary directory: \(error)")
        }
    }

}
