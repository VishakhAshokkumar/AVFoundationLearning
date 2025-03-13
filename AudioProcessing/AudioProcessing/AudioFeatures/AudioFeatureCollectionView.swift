//
//  AudioFeatureCollectionView.swift
//  AudioProcessing
//
//  Created by Vishak on 08/03/25.
//

import UIKit

protocol AudioFeatureCollectionViewDelegate: AnyObject {
    func didChangePlaybackSpeed(to speed: Float)
    func didChangeReverbEffect(to effect: String)
    func didChangePitch(to pitch: Float)
}

class AudioFeatureCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: AudioFeatureCollectionViewDelegate?
    
    private let features = ["Speed", "Reverb", "Pitch"]
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(AudioFeatureCell.self, forCellWithReuseIdentifier: "FeatureCell")
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return features.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeatureCell", for: indexPath) as? AudioFeatureCell else {
            return UICollectionViewCell()
        }
        cell.configure(for: features[indexPath.item])
        cell.onSegmentChanged = { [weak self] selectedIndex in
            switch indexPath.item {
            case 0: // Playback Speed
                let speeds: [Float] = [0.25, 0.5, 1.0, 1.25, 1.5]
                self?.delegate?.didChangePlaybackSpeed(to: speeds[selectedIndex])
            case 1: // Reverb Effect
                let effects = ["Hall", "Movie", "Room", "Plate", "Cathedral"]
                self?.delegate?.didChangeReverbEffect(to: effects[selectedIndex])
            case 2: // Pitch
                let pitches: [Float] = [-1.0, -0.5, 0.0, 0.5, 1.0]
                self?.delegate?.didChangePitch(to: pitches[selectedIndex])
            default:
                break
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 50)
    }
}
