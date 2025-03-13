//
//  PlayBackView.swift
//  AudioProcessing
//
//  Created by Vishak on 02/03/25.
//

import UIKit

class PlayBackView: UIView {
    
    // MARK: - UI Components
    
    private let playPauseButton = PlayBackView.createButton(systemImage: "play.circle.fill")
    private let previousButton = PlayBackView.createButton(systemImage: "backward.fill")
    private let nextButton = PlayBackView.createButton(systemImage: "forward.fill")
    private let backward10Button = PlayBackView.createButton(systemImage: "gobackward.10")
    private let forward10Button = PlayBackView.createButton(systemImage: "goforward.10")
    
    private let durationSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        slider.tintColor = .red
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    // MARK: - Closures for Actions
    var onPlayPauseTapped: (() -> Void)?
    var onPreviousTapped: (() -> Void)?
    var onNextTapped: (() -> Void)?
    var onBackward10Tapped: (() -> Void)?
    var onForward10Tapped: (() -> Void)?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupActions()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        backgroundColor = .black
        addSubview(durationSlider)
        addSubview(previousButton)
        addSubview(backward10Button)
        addSubview(playPauseButton)
        addSubview(forward10Button)
        addSubview(nextButton)
        
    }
    
    private func setupActions() {
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        backward10Button.addTarget(self, action: #selector(backward10Tapped), for: .touchUpInside)
        forward10Button.addTarget(self, action: #selector(forward10Tapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Duration Slider Constraints
            durationSlider.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            durationSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            durationSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Play/Pause Button Constraints
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.topAnchor.constraint(equalTo: durationSlider.bottomAnchor, constant: 20),
            playPauseButton.widthAnchor.constraint(equalToConstant: 60),
            playPauseButton.heightAnchor.constraint(equalToConstant: 60),
            
            // 10-Second Backward & Forward Buttons
            backward10Button.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -20),
            backward10Button.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            
            forward10Button.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 20),
            forward10Button.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            
            // Previous & Next Buttons
            previousButton.trailingAnchor.constraint(equalTo: backward10Button.leadingAnchor, constant: -20),
            previousButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            
            nextButton.leadingAnchor.constraint(equalTo: forward10Button.trailingAnchor, constant: 20),
            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor)
        ])
    }
    
    // MARK: - Action Handlers
    
    @objc private func playPauseTapped() {
        onPlayPauseTapped?()
    }
    
    @objc private func previousTapped() {
        onPreviousTapped?()
    }
    
    @objc private func nextTapped() {
        onNextTapped?()
    }
    
    @objc private func backward10Tapped() {
        onBackward10Tapped?()
    }
    
    @objc private func forward10Tapped() {
        onForward10Tapped?()
    }
    
    // MARK: - Helper Methods
    
    static private func createButton(systemImage: String) -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(systemName: systemImage), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func updatePlayPauseButton(isPlaying: Bool) {
        let imageName = isPlaying ? "pause.circle.fill" : "play.circle.fill"
        playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}
