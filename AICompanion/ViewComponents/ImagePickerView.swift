//
//  PhotosPickerView.swift
//  AICompanion
//
//  Created by Артур Кулик on 18.10.2024.
//

import SwiftUI

struct ImagePickerView: View {
    var imageData: (Data) -> Void
    
    var body: some View {
        PhotosPickerControllerView(imageDidSelect: imageData)
            .ignoresSafeArea(.all)
            .toolbar(.hidden)
    }
}

struct PhotosPickerControllerView: UIViewControllerRepresentable {
    
    let imagePicker = UIImagePickerController()
    var imageDidSelect: (Data) -> Void
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> some UIViewController {
        imagePicker.sourceType = .savedPhotosAlbum
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(parent: self)
        imagePicker.delegate = coordinator
        return coordinator
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: PhotosPickerControllerView
        
        init(parent: PhotosPickerControllerView) {
            self.parent = parent
        }
        
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                let data = image.pngData()
                parent.imageDidSelect(data ?? Data())
                parent.dismiss()
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
    
}
