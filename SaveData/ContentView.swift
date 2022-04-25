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
    @State var openFile: Bool = false
    //@State var camera0_or_file1: Bool = false
    @State var img: Image? = nil
    @State var imUI = UIImage()
    @State var selection1 = 0
    @State var selection2 = 0
    
    
    @State var pickerType: [String] = ["Document numérique","Tableau blanc","Feuille papier","Carte de visite", "Page de livre","Journal", "Autre"]
    @State var pickerEvent: [String] = ["Travail", "Réunion", "Projet", "Étude", "Personnel", "Loisirs"]
    
    // let dictChar: [String:String] = ["%20":" ", "e%CC%81":"é", "E%CC%81":"É"]
    
    @State var newType: String = ""
    @State var newEvent: String = ""
    
    @EnvironmentObject var vm: ImageManager
    //@EnvironmentObject var vm2: ImageManagerCloud

    var body: some View{
        if (showImage){
            Image(uiImage: self.imUI).resizable().scaledToFit()
        }
        
        VStack{
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
            
            Button(action:{
                openFile.toggle()
            }, label:{
                Text("Chercher une photo")
            }).padding(20)
            
            Picker("Choisir un type", selection: $selection1){
                ForEach(0 ..< pickerType.count){
                    Text(self.pickerType[$0]).tag($0)
                }
                .id(self.pickerType)
            }.padding(10)
            
            Picker("Choisir un événement", selection: $selection2){
                ForEach(0 ..< pickerEvent.count){
                    Text(self.pickerEvent[$0]).tag($0)
                }
                .id(self.pickerEvent)
            }.padding(10)

            
            Button(action: {
                vm.createFolder(folderName: self.pickerType[selection1])
                vm.saveImage(image: self.imUI,nomEvent: self.pickerEvent[selection2], folderName: self.pickerType[selection1]) //here we can add name's argument
                
                //vm.createDoss()

                
//                vm2.createFolder(folderName: self.pickerType[selection1])
//                vm2.saveImage(image: self.imUI,nomEvent: self.pickerEvent[selection2], folderName: self.pickerType[selection1])
//                vm2.copyToiCloud(folderN: self.pickerType[selection1])
                    //here we can add name's argument
                
            }, label: {Text("Sauvegarder")})
                .padding(20)
            
            .fileImporter(isPresented: $openFile, allowedContentTypes: [.jpeg]) { (res) in
                do{
                    let fileURL = try res.get()
                    if FileManager.default.fileExists(atPath: fileURL.path){
                        showImage = true
                        //camera0_or_file1 = true
                        let url = URL(string: fileURL.absoluteString)
                        let data = try Data(contentsOf: url!)
                        imUI = UIImage(data: data)!
                    }
                    let exprReg = ".*\\/(.*?)\\/(.*?)_.*$"
                    let matchedType = vm.matches(for: exprReg, in: fileURL.absoluteString, groupe: 1).removingPercentEncoding!
                    let matchedEvent = vm.matches(for: exprReg, in: fileURL.absoluteString, groupe: 2).removingPercentEncoding!
                    
                    if !pickerType.contains(String(matchedType)){
                        pickerType.append(matchedType)
                    }
                    if !pickerEvent.contains(String(matchedEvent)){
                        pickerEvent.append(matchedEvent)
                    }
                    
                    selection1 = pickerType.firstIndex(of: String(matchedType))!
                    selection2 = pickerEvent.firstIndex(of: String(matchedEvent))!
                    
                    print(matchedType)
                    print(matchedEvent)
                } catch {
                    print("erreur.")
                }
            }
            .sheet(isPresented: $showCaptureImageView){
                CaptureImageView(sourceType: .camera, selectedImage: $imUI)
            }
            TextField("Nouveau Type ou à Supprimer" , text: $newType)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(20)
            Button(action:{
                if !pickerType.contains(newType){
                    if !newType.isEmpty {
                        pickerType.append(newType)
                        selection1 = pickerType.firstIndex(of: newType)!
                    }
                } else {
                    if selection1 == pickerType.firstIndex(of: newType)!{
                        selection1 = 0
                    }
                    pickerType.remove(at: pickerType.firstIndex(of: newType)!)
                }
            }, label: {Text("Ajouter/Supprimer un Type")}).padding(10)
            
            TextField("Nouveau Évènement ou à Supprimer" , text: $newEvent)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(20)
            Button(action:{
                if !pickerEvent.contains(newEvent){
                    if !newEvent.isEmpty {
                        pickerEvent.append(newEvent)
                        selection2 = pickerEvent.firstIndex(of: newEvent)!
                    }
                } else {
                    if selection2 == pickerEvent.firstIndex(of: newEvent)!{
                        selection2 = 0
                    }
                    pickerEvent.remove(at: pickerEvent.firstIndex(of: newEvent)!)
                }
            }, label: {Text("Ajouter/Supprimer un Évènement")}).padding(10)
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

