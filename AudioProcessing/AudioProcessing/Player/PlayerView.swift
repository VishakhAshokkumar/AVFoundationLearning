//
//  PlayerView.swift
//  AudioProcessing
//
//  Created by Vishak on 01/03/25.
//

import UIKit

class PlayerView: UIView {
    
    
    private var albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 211/255, green: 47/255, blue: 47/255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        setupView()
    }
    
    func setupView() {
        backgroundColor = .black
        
        addSubview(albumImageView)
        addSubview(albumNameLabel)
        addSubview(artistNameLabel)
        
        
        NSLayoutConstraint.activate([
            albumImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            albumImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            albumImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8), // 60% of PlayerView width
            albumImageView.heightAnchor.constraint(equalTo: albumImageView.widthAnchor), // Maintain square aspect ratio
            
            albumNameLabel.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 20),
            albumNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            albumNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            artistNameLabel.topAnchor.constraint(equalTo: albumNameLabel.bottomAnchor, constant: 5),
            artistNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            artistNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])

        
    }
    
    func configure(from track: Track) {
        albumNameLabel.text = track.albumName
        artistNameLabel.text = track.artistName
        
        if let imageUrl = track.imageURL {
            loadImage(from: imageUrl)
        }
    }
    
    
    private func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.albumImageView.image = image
                }
            }
        }
        
    }
    
}



