//
//  AudioFeatureCell.swift
//  AudioProcessing
//
//  Created by Vishak on 08/03/25.
//

import UIKit

class AudioFeatureCell: UICollectionViewCell {
    
    private let titleLabel = UILabel()
    private let segmentedControl = UISegmentedControl()
    
    var onSegmentChanged: ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        contentView.layer.cornerRadius = 10
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textAlignment = .center
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, segmentedControl])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .center
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(for feature: String) {
        titleLabel.text = feature
        
        segmentedControl.removeAllSegments()
        
        switch feature {
        case "Speed":
            let speeds = ["0.25", "0.5", "1", "1.25", "1.5"]
            for (index, speed) in speeds.enumerated() {
                segmentedControl.insertSegment(withTitle: speed, at: index, animated: false)
            }
            segmentedControl.selectedSegmentIndex = 2 // Default: 1x
        case "Reverb":
            let effects = ["Hall", "Movie", "Room", "Plate", "Cathedral"]
            for (index, effect) in effects.enumerated() {
                segmentedControl.insertSegment(withTitle: effect, at: index, animated: false)
            }
            segmentedControl.selectedSegmentIndex = 0
        case "Pitch":
            let pitches = ["-1", "-0.5", "0", "0.5", "1"]
            for (index, pitch) in pitches.enumerated() {
                segmentedControl.insertSegment(withTitle: pitch, at: index, animated: false)
            }
            segmentedControl.selectedSegmentIndex = 2 // Default: 0
        default:
            break
        }
    }
    
    @objc private func segmentChanged() {
        onSegmentChanged?(segmentedControl.selectedSegmentIndex)
    }
}

