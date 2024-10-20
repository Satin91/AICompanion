//
//  CameraView.swift
//  AICompanion
//
//  Created by Артур Кулик on 18.10.2024.
//

import SwiftUI
import AVKit
import RealityKit
import ARKit

struct CameraView: View {
    @StateObject var cameraManager = CameraManager()
    let generator = UIImpactFeedbackGenerator(style: .medium)
    var shotData: (Data) -> Void
    @Environment(\.dismiss) var dismiss
    @State private  var zoom: CGFloat = 1
    @State private var previousZoomValue: CGFloat = 1
    
    var body: some View {
        content
            .onAppear {
                Task {
                    let isAutorized = await cameraManager.checkAccess()
                    if isAutorized {
                    } else {
                        dismiss()
                    }
                }
            }
            .gesture(
                MagnificationGesture()
                    .onChanged { val in
                        changeCameraScale(gesture: val)
                    }.onEnded { val in
                        self.previousZoomValue = 1
                    }
            )
            .background(Color.black)
            .ignoresSafeArea(.all)
    }
    
    var content: some View {
        ZStack {
            VStack(spacing: .zero) {
                topPanelContainer
                ZStack {
                    camera
                    photo
                }
            }
            bottomPanelContainer
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
    
    var topPanelContainer: some View {
        Rectangle()
            .fill(.black)
            .frame(height: 150)
            .overlay {
                HStack {
                    flashButton
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        Spacer()
                }
                .padding(Layout.Padding.horizontalEdges)
            }
    }
    
    var camera: some View {
        CameraPreview(cameraManager: cameraManager)
    }
    
    @ViewBuilder var photo: some View {
        if let data = cameraManager.capturedPhotoData {
            Image(uiImage: UIImage(data: data)!)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)
        }
    }
    
    var bottomPanelContainer: some View {
        Rectangle()
            .fill(.black.opacity(0.7))
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
    
    var flashButton: some View {
        Button {
            cameraManager.flipFlashState()
        } label: {
            let imageName = cameraManager.isFlashEnamle ? "bolt.fill" : "bolt.slash.fill"
            Image(systemName: imageName)
                .font(.system(size: 22))
                .foregroundColor(Color.white)
        }
        .buttonStyle(.plain)

    }
    
    let queue = DispatchQueue(label: "dddqueue", qos: .userInteractive)
    
    var shootingPhotoPanel: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .fontWeight(.light)
                    .scaledToFit()
                    .frame(width: 22, height: 22)
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
            
            Button {
                queue.async {
                    self.generator.impactOccurred()
                    self.cameraManager.switchCamera()
                }
                    
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
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
    
    var photoTakenPanel: some View {
        HStack {
            Spacer()
                .frame(maxWidth: .infinity)
            Button {
                print("Close controller, send the photo")
                dismiss()
                shotData(cameraManager.capturedPhotoData ?? Data())
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
                cameraManager.startShooting()
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
    
    private func changeCameraScale(gesture value: CGFloat) {
        var startFlip: CGFloat = 0
        
        let delta = value / self.previousZoomValue
        var newScale = (self.zoom * delta)
        
        if previousZoomValue == 1 { // Это условие убирает начальный скачек зума
            startFlip = self.zoom - newScale
        }

        self.previousZoomValue = value
        newScale += startFlip // startFlip убирает люфт на первом обновлении
        guard (1...115).contains(newScale) else { return }
        self.zoom = newScale
        cameraManager.zoom(to: zoom)
    }
}

final class CameraManager: NSObject, ObservableObject {
    
    private var currentDevice: AVCaptureDevice?
    private var output = AVCapturePhotoOutput()
    private var frontCamera: AVCaptureDevice?
    private var backCamera: AVCaptureDevice?
    var session = AVCaptureSession()
    var preview: AVCaptureVideoPreviewLayer!
    @Published var state = CameraState.shooting
    @Published var isFlashEnamle = false
    private var generator = UIImpactFeedbackGenerator(style: .light)
    
    var queue = DispatchQueue(label: "com.aicompanion.arthur.backgroundThread")
    var capturedPhotoData: Data?
    
    enum CameraState {
        case shooting
        case shotTaken
    }

    func takeShot() {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = isFlashEnamle ? .on : .off
        generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        self.output.capturePhoto(with: photoSettings, delegate: self)
        
      
    }
    
    func flipFlashState() {
        isFlashEnamle.toggle()
    }
    
    func startShooting() {

        queue.async {
            self.session.startRunning()
        }
        DispatchQueue.main.async {
            self.state = .shooting
            self.capturedPhotoData = nil
        }
    }
    
    func checkAccess() async -> Bool {
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
    
    func zoom(to: CGFloat) {
        try? currentDevice?.lockForConfiguration()
        currentDevice?.videoZoomFactor = to
        currentDevice?.unlockForConfiguration()
    }
    
    func setup() {
        let backCamera = findCurrentDevice()
        let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        
        guard let backCamera = backCamera,
              let frontCamera = frontCamera
        else {
            fatalError("device not configurated")
        }
        
        self.backCamera = backCamera
        self.frontCamera = frontCamera
        
        guard let backInput = try? AVCaptureDeviceInput(device: backCamera) else {
            fatalError("device input not captured")
        }
        
        guard let frontInput = try? AVCaptureDeviceInput(device: frontCamera) else {
            fatalError("device input not captured")
        }
        
        queue.async { [unowned self] in
            session.beginConfiguration()
            
            if session.canAddInput(backInput) {
                session.addInput(backInput)
            }
            
            if session.canAddInput(frontInput) {
                session.addInput(frontInput)
            }
            
            if session.canAddOutput(self.output) {
                output.isHighResolutionCaptureEnabled = true
                output.maxPhotoQualityPrioritization = .balanced
                session.addOutput(self.output)
            }
            
            self.currentDevice = backCamera
            
            session.commitConfiguration()
        }

    }
    
    func switchCamera() {
        queue.async { [unowned self] in
            
        
        session.beginConfiguration()
        let currentInput = session.inputs.first as? AVCaptureDeviceInput
        session.removeInput(currentInput!)

        let newCameraDevice = currentInput?.device.position == .back ? frontCamera : backCamera
        self.currentDevice = newCameraDevice
        let newVideoInput = try? AVCaptureDeviceInput(device: newCameraDevice!)
        session.addInput(newVideoInput!)
        session.commitConfiguration()
        }
    }
    
    private func findCurrentDevice() -> AVCaptureDevice? {

            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTripleCamera, .builtInDualWideCamera, .builtInDualCamera, .builtInWideAngleCamera],
                                                                    mediaType: .video,
                                                                    position: .back)
            guard let device = discoverySession.devices.first else {
                return nil
            }
        
            return device

    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else { return }
        state = .shotTaken
        
        DispatchQueue.main.async {
            self.session.stopRunning()
        }
        guard let imageData = photo.fileDataRepresentation() else { return }
        print("size of image", imageData)
        self.capturedPhotoData = imageData
        queue.asyncAfter(deadline: .now() + 0.4) {
            self.session.startRunning()
        }
    }
    
}

struct CameraPreview: UIViewControllerRepresentable {
    
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        cameraManager.preview.frame = context.coordinator.view.bounds
    }
    
    
    @ObservedObject var cameraManager: CameraManager
    
    init(cameraManager: CameraManager) {
        self.cameraManager = cameraManager
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        cameraManager.preview = AVCaptureVideoPreviewLayer(session: cameraManager.session)
        context.coordinator.view.layer.addSublayer(cameraManager.preview)
        return context.coordinator
    }
    
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(cameraPreview: self)
    }
    
    final class Coordinator: UIViewController {
        var cameraPreview: CameraPreview
        
        init(cameraPreview: CameraPreview) {
            self.cameraPreview = cameraPreview
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            cameraPreview.cameraManager.startShooting()
        }
    }
}
