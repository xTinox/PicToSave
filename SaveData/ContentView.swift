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
    @State var urlPDF_JPG = URL(string:"")
    
    @State var pickerType: [String] = ["Document numérique","Tableau blanc","Feuille papier","Carte de visite", "Page de livre","Journal", "Autre"]
    @State var pickerEvent: [String] = ["Travail", "Réunion", "Projet", "Étude", "Personnel", "Loisirs"]
    
    @State var newType: String = ""
    @State var newEvent: String = ""
    
    @EnvironmentObject var vm: ImageManager
    @ObservedObject var sc: ScanView
    //let coreDataController: DataController
    //@EnvironmentObject var vm2: ImageManagerCloud
    
    @State private var showAlert = false
    @State private var selectedTab = 1

    var body: some View{
        
        VStack{
            Spacer()
            VStack{
                HStack(spacing: 40.0){
                    VStack{
                        Label("Type",systemImage: "doc")
                        Picker("Choisir un type", selection: $selection1){
                            ForEach(0 ..< pickerType.count){
                                Text(self.pickerType[$0]).tag($0)
                            }
                            .id(self.pickerType)
                        }.padding(10)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray,lineWidth: 3))
                    }
                    VStack{
                        Label("Évènement", systemImage: "rectangle.on.rectangle.square")
                        Picker("Choisir un événement", selection: $selection2){
                            ForEach(0 ..< pickerEvent.count){
                                Text(self.pickerEvent[$0]).tag($0)
                            }
                            .id(self.pickerEvent)
                        }.padding(10)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray,lineWidth: 3))
                    }
                }
            }
            ScrollView(.horizontal){
                HStack {
                    if (!sc.imageArray.isEmpty){
                        ForEach(sc.imageArray, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250, height: 300)
                        }
                    }
                }
            }
            if !(sc.imageArray.isEmpty){
                HStack{
                    Spacer()
                    Button(action:{
                        showAlert = true
                    }, label :{
                        Text("Supprimer")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.red)
                        Image(systemName: "trash")
                    })
                    .foregroundColor(Color.red)
                    .padding(.all,10)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.red,lineWidth: 3))
                    .disabled(sc.imageArray.isEmpty)
                    .alert("Voulez-vous vraiment supprimer l'intégralité des photos prises/affichées ci-dessus",isPresented: $showAlert){
                        Button("Oui"){sc.imageArray.removeAll()}
                        Button("Non"){}
                    }
                    Spacer()
                    Button(action: {
                        if !(sc.imageArray.isEmpty){
                            ///vm.saveImage(image: self.imUI,nomEvent: self.pickerEvent[selection2], folderName: self.pickerType[selection1])
                            vm.saveAsPDF(images: sc.imageArray, nomEvent: self.pickerEvent[selection2], folderName: self.pickerType[selection1])
                        }
                        else{
                            print("Aucune photo")
                        }
                    }, label: {Text("Sauvegarder")})
                        .font(.title)
                        .padding(20.0)
                        .foregroundColor(Color.green)
                        .frame(width: 200.0, height: 50.0)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.green,lineWidth: 10))
                    Spacer()
                }
            }
            
            TabView(selection: $selectedTab) {
                VStack(spacing: 20.0){
                    Button(action:{
                        UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController?.present(sc.getDocumentCameraViewController(), animated: true, completion: nil)
                        //showCaptureImageView.toggle()
                        openFile = false
                        showImage = true
                    }, label:{
                        Text("Prendre des photos")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.blue)
                            
                        Image(systemName: "camera")
                            .resizable(resizingMode: .tile)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.blue)
                            .frame(width: /*@START_MENU_TOKEN@*/50.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/50.0/*@END_MENU_TOKEN@*/)
                        
                    })
                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                    //Image(systemName: "camera")
                    .frame(width: 300.0, height: 100.0)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.blue,lineWidth: 3))
                    
                    
                    Button(action:{
                        openFile.toggle()
                    },label:{
                        Text("Choisir un document")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.green)
                        Image(systemName: "doc.badge.plus")
                            .resizable(resizingMode: .tile)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.green)
                            .frame(width: /*@START_MENU_TOKEN@*/50.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/50.0/*@END_MENU_TOKEN@*/)
                    })
                    .padding(10)
                    .frame(width: 300.0, height: 100.0)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.green,lineWidth: 3))
                    .fileImporter(isPresented: $openFile, allowedContentTypes: [.pdf,.jpeg]) { (res) in
                    do{
                        let fileURL = try res.get()
                        
                        if FileManager.default.fileExists(atPath: fileURL.path){
                            self.urlPDF_JPG = URL(string: fileURL.absoluteString)
                            //sc.imageArray.removeAll()
                            if (fileURL.pathExtension=="pdf" || fileURL.pathExtension=="PDF"){
                                sc.imageArray += vm.pdfToImages(url: self.urlPDF_JPG!)!
                            }
                            else if (fileURL.pathExtension=="jpg" || fileURL.pathExtension=="JPG"){
                                let data = try Data(contentsOf: urlPDF_JPG!)
                                imUI = UIImage(data: data)!
                                sc.imageArray.append(imUI)
                            }
                            else{
                                print(fileURL.pathExtension)
                            }
                            showImage = true
                            
                            
                        }
                        var exprReg = ".*\\/(.*?)\\/(.*?)\\/.*?$"
                        let matches1 = vm.matches(for: exprReg, in: fileURL.absoluteString, groupe: 1).removingPercentEncoding!
                        let matches2 = vm.matches(for: exprReg, in: fileURL.absoluteString, groupe: 2).removingPercentEncoding!
                        
                        print(matches1)
                        print(matches2)
                        
                        if (matches1=="iCloud~pictosave" || matches2==vm.recentsFiles){
                            exprReg = ".*\\/(.*?)-(.*?)_.*$"
                        }
                        else{
                            exprReg = ".*\\/(.*?)\\/(.*?)_.*$"
                        }
                        
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
                }.tabItem { Image(systemName: "camera.on.rectangle");Text("Capture") }.tag(1)
                
                VStack(spacing : 30){
                    Label{
                        Text("Ajouter ou Supprimer").font(.title).fontWeight(.bold).underline()
                    } icon:{
                        
                    }
                    HStack{
                        Text("Type :")
                            .font(.title3)
                            .padding(.horizontal, 10)
                        TextField("Type à Ajouter ou Supprimer" , text: $newType)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.trailing, 20)
                            .padding(.top, 10)
                        if (!newType.isEmpty) && !pickerType.contains(newType){
                            Button(action:{
                                pickerType.append(newType)
                                selection1 = pickerType.firstIndex(of: newType)!
                            }, label: {
                                Text("Ajouter")
                                Image(systemName: "plus")
                            }).padding(10)
                        }
                        if (pickerType.contains(newType)){
                            Button(action:{
                                if selection1 == pickerType.firstIndex(of: newType)!{
                                    selection1 = 0
                                }
                                pickerType.remove(at: pickerType.firstIndex(of: newType)!)
                            }, label: {
                                Text("Supprimer")
                                Image("plus")
                            }).padding(10)
                        }
                    }
                    HStack{
                        Text("Évènement :")
                            .font(.title3)
                            .padding(.horizontal, 10)
                        TextField("Évènement à Ajouter ou Supprimer" , text: $newEvent)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.trailing, 20)
                        if (!newEvent.isEmpty && !pickerEvent.contains(newEvent)){
                            Button(action:{
                                if !pickerEvent.contains(newEvent){
                                    if !newEvent.isEmpty {
                                        pickerEvent.append(newEvent)
                                        selection2 = pickerEvent.firstIndex(of: newEvent)!
                                    }
                                }
                            }, label: {Text("Ajouter")}).padding(10)
                        }
                        if(pickerEvent.contains(newEvent)){
                            Button(action:{
                                if pickerEvent.contains(newEvent){
                                    if selection2 == pickerEvent.firstIndex(of: newEvent)!{
                                        selection2 = 0
                                    }
                                    pickerEvent.remove(at: pickerEvent.firstIndex(of: newEvent)!)
                                }
                            }, label: {Text("Supprimer")}).padding(10)
                        }
                    }
                }.tabItem { Image(systemName: "slider.horizontal.3")
                    Text("Type / Évènement")
                }.tag(2)
                
                VStack{
                Text("Tab Content 3")
                
                
                }.tabItem { Image(systemName: "info") }.tag(3)
            }
        

            //Image(uiImage: self.imUI).resizable().scaledToFit()
        
            
            
            

            
            
        }
    }
    /*
    private func makeScannerView () -> ScanDocuments{
        ScanDocuments(completion: ($imUI)?)
    }
    */
}
/*
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
    
    @State var newType: String = ""
    @State var newEvent: String = ""
    @State var selection1 = 0
    @State var selection2 = 0
    
    @State var isTapped = false
    
    
    @State var pickerType: [String] = ["Document numérique","Tableau blanc","Feuille papier","Carte de visite", "Page de livre","Journal", "Autre"]
    @State var pickerEvent: [String] = ["Travail", "Réunion", "Projet", "Étude", "Personnel", "Loisirs"]
    
    @EnvironmentObject var vm: ImageManager
    //@EnvironmentObject var vm2: ImageManagerCloud
        
    var body: some View {
        if (showImage){
            Image(uiImage: self.imUI).resizable().scaledToFit()
        }
        //TabView{
        NavigationView {
            Text("Hello, World!").padding()
                .navigationTitle("PicToShare")
              //  .toolbar {
            //ToolbarItemGroup(placement: .bottomBar) {
        }
               
                Button(action:{
                    //TODO : une vue qui accède à l'appareil photo
                    /*showCaptureImageView.toggle()
                    showImage = true
                    if !(showImage){
                        Image(systemName: "camera")
                            ._colorMonochrome(.black)
                            .padding(10)
                    }
                    else{
                        Text("Prendre une autre photo")
                            ._colorMonochrome(.black)
                    }
                     
                     Button(action: {
                         vm.createFolder(folderName: self.pickerType[selection1])
                         vm.saveImage(image: self.imUI,nomEvent: self.pickerEvent[selection2], folderName: self.pickerType[selection1]) //here we can add name's argument
                         
                         //vm.createDoss()
                         
         //                vm2.createFolder(folderName: self.pickerType[selection1])
         //                vm2.saveImage(image: self.imUI,nomEvent: self.pickerEvent[selection2], folderName: self.pickerType[selection1])
         //                vm2.copyToiCloud(folderN: self.pickerType[selection1])
                             //here we can add name's argument
                         
                     }, label: {Text("Sauvegarder")})
                         .padding(20)*/
                    
                }, label:{
                        Image(systemName: "camera")
                            ._colorMonochrome(.black)
                            .padding(10)
                })
                Spacer()
                
                
                NavigationLink(destination: encoreuneautreView(),
                               isActive: Binding<Bool>(get: { isTapped },
                            set: { isTapped = $0; openFile.toggle() })) {
                    Image(systemName: "photo")
                        ._colorMonochrome(.black)
                }
                Spacer()
                
                NavigationLink(destination: autreView()) {
                    Image(systemName: "folder.badge.gearshape")
                        ._colorMonochrome(.black)
                }
                
            }

        
            /*
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
             */
    }

    

struct autreView: View {
    
    @State var newType: String = ""
    @State var newEvent: String = ""
    @State var selection1 = 0
    @State var selection2 = 0
    
    @State var pickerType: [String] = ["Document numérique","Tableau blanc","Feuille papier","Carte de visite", "Page de livre","Journal", "Autre"]
    @State var pickerEvent: [String] = ["Travail", "Réunion", "Projet", "Étude", "Personnel", "Loisirs"]
    
var body: some View {
    
    Text("Gérer les types d'évènement et de document")
        .font(.title.weight(.bold))
        ._colorMonochrome(.black)
    
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
    }, label: {Text("Ajouter ou supprimer un type de document")})
            .padding(10)
            ._colorMonochrome(.black)
            .padding(5)

    
    TextField("Document" , text: $newType)
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
    }, label: {Text("Ajouter ou supprimer un type d'évènement")
            ._colorMonochrome(.black)
    }).padding(10)
    
    TextField("Évènement" , text: $newEvent)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding(20)
    
    }
}


struct encoreuneautreView: View {
    
    @State var openFile: Bool = false
    
    @State var selection1 = 0
    @State var selection2 = 0
    @State var selection3 = 0
    
    @State var pickerType: [String] = ["Document numérique","Tableau blanc","Feuille papier","Carte de visite", "Page de livre","Journal", "Autre"]
    @State var pickerEvent: [String] = ["Travail", "Réunion", "Projet", "Étude", "Personnel", "Loisirs"]
    @State var pickerParam: [String] = ["Type", "Évènement"]
    
var body: some View {
    
    //TODO : mettre la HStack en haut de l'appel à la gallerie
    VStack{
        
        HStack(alignment: .top){
            Picker("Choisir un type", selection: $selection1){
                ForEach(0 ..< pickerType.count){
                    Text(self.pickerType[$0]).tag($0)
                        ._colorMonochrome(.black)

                }
                .id(self.pickerType)
            }.padding(10)
            
            Spacer()
            
            Picker("Choisir un événement", selection: $selection2){
                ForEach(0 ..< pickerEvent.count){
                    Text(self.pickerEvent[$0]).tag($0)
                        ._colorMonochrome(.black)

                }
                .id(self.pickerEvent)
            }.padding(10)
        /*Picker("Choix des paramètres du document",selection: $selection3){
            Text("Type").tag(0)
            Text("Évènement").tag(1)
        }.pickerStyle(.segmented)*/
        }
        
        HStack(alignment: .bottom){
        //ici avec les options sauvegarder et prendre une autre photo
        }
    }

    
}
}

 */

struct Content_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(sc: ScanView())
            
    }
}


