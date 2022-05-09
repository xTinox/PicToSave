//
//  ContentView.swift
//  SaveData
//
//  Created by Tino on 21/03/2022.
//

import SwiftUI
import Foundation
import UIKit
import PDFKit


struct ContentView: View{
    @State var showCaptureImageView: Bool = false
    @State var showImage: Bool = false
    @State var openFile: Bool = false
    @State var showPDF: Bool = false
    
    @State var fromCam: Bool = false
    @State var fromFile: Bool = false
    
    //@State var camera0_or_file1: Bool = false
    @State var img: Image? = nil
    @State var imUI = UIImage()
    @State var selection1 = 0
    @State var selection2 = 0
    @State var images: [UIImage] = []
    @State var urlPDF = URL(string:"")
    
    @State var pickerType: [String] = ["Document numérique","Tableau blanc","Feuille papier","Carte de visite", "Page de livre","Journal", "Autre"]
    @State var pickerEvent: [String] = ["Travail", "Réunion", "Projet", "Étude", "Personnel", "Loisirs"]
    
    @State var newType: String = ""
    @State var newEvent: String = ""
    
    @EnvironmentObject var vm: ImageManager
    @ObservedObject var sc: ScanView
    //@EnvironmentObject var vm2: ImageManagerCloud
    
    @State private var showAlert = false

    var body: some View{
        HStack{
            if (showImage){
                ForEach(sc.imageArray, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            }
        }

            //Image(uiImage: self.imUI).resizable().scaledToFit()
        
        VStack{
            Button("Supprimer"){
                showAlert = true
            }
            .foregroundColor(Color.red)
            .padding(10)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.red,lineWidth: 5))
            .disabled(sc.imageArray.isEmpty)
            .alert("Voulez-vous vraiment supprimer l'intégralité des photos prises/affichées ci-dessus",isPresented: $showAlert){
                Button("Oui"){sc.imageArray.removeAll()}
                Button("Non"){}
            }
            HStack{
                Button(action:{
                    UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController?.present(sc.getDocumentCameraViewController(), animated: true, completion: nil)
                    //showCaptureImageView.toggle()
                    openFile = false
                    showImage = true
                }, label:{
                    if !(showImage){
                        Text("Prendre une photo")
                    }
                    else{
                        Text("Prendre une autre photo")
                    }
                }).padding(10)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue,lineWidth: 5))
                
                Button("Chercher une photo"){
                    openFile.toggle()
                }
                .padding(10)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.green,lineWidth: 5))
            }
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
                if !(sc.imageArray.isEmpty){
                    vm.createFolder(folderName: self.pickerType[selection1])
                    ///vm.saveImage(image: self.imUI,nomEvent: self.pickerEvent[selection2], folderName: self.pickerType[selection1])
                    vm.saveAsPDF(images: sc.imageArray, nomEvent: self.pickerEvent[selection2], folderName: self.pickerType[selection1])
                }
                else{
                    print("Aucune photo")
                }
            }, label: {Text("Sauvegarder")})
                .font(.title)
                .padding(20)
            
            .fileImporter(isPresented: $openFile, allowedContentTypes: [.pdf]) { (res) in
                do{
                    let fileURL = try res.get()
                    if FileManager.default.fileExists(atPath: fileURL.path){
                        ///showImage = false
                        
                        //camera0_or_file1 = true
                        self.urlPDF = URL(string: fileURL.absoluteString)
                        sc.imageArray.removeAll()
                        sc.imageArray = vm.pdfToImages(url: self.urlPDF!)!
                        ///let data = try Data(contentsOf: url!)
                        ///imUI = UIImage(data: data)!
                        showImage = true
                        
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
                
                
                ///UIActivityViewController(activityItems: sc.$imageArray, applicationActivities: nil)
                
                
                //makeScannerView()
                //CaptureImageView(sourceType: .camera, selectedImage: $imUI)
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
    /*
    private func makeScannerView () -> ScanDocuments{
        ScanDocuments(completion: ($imUI)?)
    }
    */
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
