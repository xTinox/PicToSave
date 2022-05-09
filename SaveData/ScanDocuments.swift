//
//  ScanDocuments.swift
//  SaveData
//
//  Created by Tino on 02/05/2022.
//

import VisionKit
import SwiftUI

struct ScanDocuments: UIViewControllerRepresentable{
    
    typealias UIViewControllerType = VNDocumentCameraViewController
    private let completionHandler: (Binding<UIImage>?) -> UIImage
    
    init(completion: @escaping (Binding<UIImage>?) -> UIImage){
        self.completionHandler = completion
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(completion: completionHandler)
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
    }
    
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let completionHandler: (Binding<UIImage>?) -> UIImage
        
        init(completion: @escaping (Binding<UIImage>?) -> UIImage){
            self.completionHandler = completion
        }
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            completionHandler(nil)
        }
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            for pageNumber in 0..<scan.pageCount{
                let image = scan.imageOfPage(at: pageNumber)
            }
        }
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            completionHandler(nil)
        }
    }
}
