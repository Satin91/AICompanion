//
//  CameraView.swift
//  AICompanion
//
//  Created by Артур Кулик on 18.10.2024.
//

import SwiftUI
import AVKit

struct CameraView: View {
    @StateObject var cameraManager = CameraSettings()
    var shotData: (Data) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        content
            .onAppear {
                Task {
                    let isAutorized = await cameraManager.checkAccess()
                    if isAutorized {
                        cameraManager.continueShooting()
                    } else {
                        dismiss()
                        
                    }
                }
            }
            .onTapGesture {
                print("Tap")
            }
            .ignoresSafeArea(.all)
    }
    
    var content: some View {
        ZStack {
            VStack(spacing: .zero) {
                cameraTopPanelContainer
                camera
            }
            cameraBottomPanelContainer
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
    
    var cameraTopPanelContainer: some View {
        Rectangle()
            .fill(.black)
            .frame(height: 160)
    }
    
    var camera: some View {
        CameraPreview(cameraManager: cameraManager)
    }
    
    var cameraBottomPanelContainer: some View {
        Rectangle()
            .fill(.black.opacity(0.5))
            .ignoresSafeArea(.all)
            .padding(.bottom, 20)
            .background(.thinMaterial)
            .frame(height: 150)
            .overlay {
                switch cameraManager.state {
                case .shooting:
                    shootingPhotoPanel
                case .shotTaken:
                    photoTakenPanel
                }
            }
    }
    
    var shootingPhotoPanel: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .resizable()
                    .fontWeight(.light)
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(15)
            }
            .frame(maxWidth: .infinity)
            
            Button {
                cameraManager.takeShot()
            } label: {
                Circle()
                    .foregroundColor(Color.white)
                    .frame(height: 60)
                    .padding(4)
                    .overlay {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    }
            }
            .frame(maxWidth: .infinity)
            Spacer()
                .frame(maxWidth: .infinity)
        }
    }
    
    var photoTakenPanel: some View {
        HStack {
            Spacer()
                .frame(maxWidth: .infinity)
            Button {
                print("Close controller, send the photo")
                cameraManager.send { photoData in
                    shotData(photoData)
                    dismiss()
                }
            } label: {
                Image(systemName: "arrow.up")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.white)
                    .padding(15)
                    .background(
                        Circle()
                            .foregroundColor(Color.blue)
                    )
            }
            .frame(maxWidth: .infinity)
            
            Button {
                cameraManager.continueShooting()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .resizable()
                    .fontWeight(.light)
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(15)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

final class CameraSettings: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var showCamera: Bool = false
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    @Published var state = CameraState.shooting
    
    var queue = DispatchQueue(label: "com.aicompanion.arthur.backgroundThread")
    private var shotData: Data?
    var shot: (Data) -> Void = { _ in }
    
    enum CameraState {
        case shooting
        case shotTaken
    }
    
    func send(_ completion: (Data) -> Void) {
        guard let data = shotData else { return }
        completion(data)
    }
    
    func takeShot() {
        self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    func continueShooting() {
        state = .shooting
        queue.async {
            self.session.startRunning()
        }
    }
    
    func checkAccess () async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setup()
            return true
        case .notDetermined:
            return await withUnsafeContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { [weak self] success in
                if success {
                    continuation.resume(returning: true)
                    self?.setup()
                } else {
                    continuation.resume(returning: false)
                }
            }
            }
        case .denied:
            return false
        default:
            break
        }
        return false
        
    }
    
    func setup() {
        
        guard let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) else {
            fatalError("device not configurated")
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            fatalError("device input not captured")
        }
        
        session.beginConfiguration()
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(self.output) {
            session.addOutput(self.output)
        }
        
        session.commitConfiguration()
    }
}

extension CameraSettings: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else { return }
        state = .shotTaken
        DispatchQueue.main.async {
            self.session.stopRunning()
        }
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        self.shotData = imageData
    }
}

struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var cameraManager: CameraSettings
    
    var queue = DispatchQueue(label: "com.aicompanion.arthur.backgroundThread", qos: .userInteractive)
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        cameraManager.preview = AVCaptureVideoPreviewLayer(session: cameraManager.session)
        cameraManager.preview.frame = view.frame
        cameraManager.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(cameraManager.preview)
        return view
    }
    
    
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
