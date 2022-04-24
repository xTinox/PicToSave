//
//  ContentView.swift
//  SaveData
//
//  Created by Tino on 21/03/2022.
//

import SwiftUI
import Foundation
import UIKit


struct ContentView: View{
    @State var showCaptureImageView: Bool = false
    @State var showImage: Bool = false
    @State var img: Image? = nil
    @State var imUI = UIImage()
    @State var selection1 = 0
    @State var selection2 = 0
    
    @State var pickerType: [String] = ["Document numérique","Tableau blanc","Feuille papier","Carte de visite", "Page de livre","Journal", "Autre"]
    @State var pickerEvent: [String] = ["Travail", "Reunion", "Projet", "Étude", "Personnel", "Loisirs"]
    
    @EnvironmentObject var vm: ImageManager
    //@EnvironmentObject var vm2: ImageManagerCloud

    var body: some View{
        if (showImage){
            Image(uiImage: self.imUI).resizable().scaledToFit()
        }
        
        HStack{
            Button(action:{
                showCaptureImageView.toggle()
                showImage = true
            }, label:{
                if !(showImage){
                    Text("Prendre une photo")
                }
                else{
                    Text("Prendre une autre photo")
                }
            }).padding(20)
            
            Picker("Choisir un type", selection: $selection1){
                ForEach(0 ..< pickerType.count){
                    Text(self.pickerType[$0]).tag($0)
                }
            }.padding(10)

            
            Picker("Choisir un événement", selection: $selection2){
                ForEach(0 ..< pickerEvent.count){
                    Text(self.pickerEvent[$0]).tag($0)
                }
            }.padding(10)

            
            Button(action: {
                vm.createFolderSiBesoin(folderName: self.pickerType[selection1])
                vm.saveImage(image: self.imUI,nomEvent: self.pickerEvent[selection2], folderName: self.pickerType[selection1]) //here we can add name's argument
                
                //vm.createDoss()

                
//                vm2.createFolderSiBesoin(folderName: self.pickerType[selection1])
//                vm2.saveImage(image: self.imUI,nomEvent: self.pickerEvent[selection2], folderName: self.pickerType[selection1])
//                vm2.copyToiCloud(folderN: self.pickerType[selection1])
                    //here we can add name's argument
                
            }, label: {Text("Sauvegarder")})
                .padding(20)
            
            .sheet(isPresented: $showCaptureImageView){
                CaptureImageView(sourceType: .camera, selectedImage: $imUI)
            }
        }
    }
}


struct CaptureImageView: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage
    @Environment(\.presentationMode) private var presentationMode
    func makeUIViewController(context: UIViewControllerRepresentableContext<CaptureImageView>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CaptureImageView>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CaptureImageView
        init(_ parent: CaptureImageView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

