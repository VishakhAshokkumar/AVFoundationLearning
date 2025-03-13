//
//  ViewController.swift
//  AVFTutorial
//
//  Created by Vishak on 18/02/25.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // Capture session
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var videoOutput: AVCaptureMovieFileOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // UI elements
    let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Capture", for: .normal)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 35
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let modeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Photo", "Video"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermissions()
        configureUIElements()
    }
    
    // ✅ Request Camera Permission
    func checkCameraPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    self.setUpCamera()
                } else {
                    print("❌ Camera permission denied")
                }
            }
        }
    }
    
    func setUpCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            print("❌ Failed to access the camera")
            return
        }
        
        captureSession.addInput(input)
        
        // Initialize outputs
        photoOutput = AVCapturePhotoOutput()
        photoOutput.isHighResolutionCaptureEnabled = true
        
        videoOutput = AVCaptureMovieFileOutput()
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        } else {
            print("❌ Failed to add photo output")
        }
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            print("❌ Failed to add video output")
        }
        
        // Set up preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
}

// MARK: - UI Configuration
extension ViewController {
    func configureUIElements() {
        view.addSubview(captureButton)
        view.addSubview(modeSegmentedControl)
        
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70),
            
            modeSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modeSegmentedControl.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -20),
            modeSegmentedControl.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        captureButton.addTarget(self, action: #selector(captureMedia), for: .touchUpInside)
        modeSegmentedControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
    }
    
    @objc
    func modeChanged() {
        captureButton.setTitle(modeSegmentedControl.selectedSegmentIndex == 0 ? "Capture" : "Record", for: .normal)
    }
    
    @objc
    func captureMedia() {
        if modeSegmentedControl.selectedSegmentIndex == 0 {
            capturePhoto()
        } else {
            toggleVideoRecording()
        }
    }
    
    func capturePhoto() {
        guard let photoOutput = photoOutput else {
            print("❌ Photo output is nil")
            return
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        settings.isHighResolutionPhotoEnabled = true
        
        print("📸 Capturing Photo...") // Debugging print
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func toggleVideoRecording() {
        if isRecording {
            videoOutput.stopRecording()
            captureButton.backgroundColor = .red
        } else {
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mov")
            videoOutput.startRecording(to: outputURL, recordingDelegate: self)
            captureButton.backgroundColor = .gray
        }
        isRecording.toggle()
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("📸 Delegate Method Called") // Debugging print
        
        if let error = error {
            print("❌ Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            print("❌ Could not get image data")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        print("✅ Image saved to Gallery")
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension ViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("❌ Error saving video: \(error.localizedDescription)")
        } else {
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
            print("🎥 Video saved to gallery")
        }
    }
}
