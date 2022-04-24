//
//  ImageManager.swift
//  SaveData
//
//  Created by Tino on 25/03/2022.
//

import Foundation
import SwiftUI
import UIKit

class ImageManager: ObservableObject{
    
    @Published var showPicker = false
    @Published var uiImg: UIImage?
    
    func showPhotoPicker() {
        showPicker = true
    }
    
    init(){}
    
    func getImage(imageName: String, folderName:String) -> UIImage? {
        guard let url = getURLForImage(imageName: imageName, folderNa: folderName), FileManager.default.fileExists(atPath: url.path) else {return nil}
        return UIImage(contentsOfFile: url.path)
    }
    
    func getNameImage(nomEvent: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let fileName = dateFormatter.string(from: Date())
        let imageName = nomEvent + "_" + fileName
        return imageName
    }
    
    func createFolderSiBesoin(folderName: String){
        guard let url = getURLForFolder(folderN: folderName) else {print("Non");return}
        if !FileManager.default.fileExists(atPath: url.path){
        do{
            try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
        }
            catch {
                print("Error creating directory")
            }
        }
    }
    
    func getURLForFolder(folderN: String) -> URL? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return nil}
        return url.appendingPathComponent(folderN)
    }
    
    func getURLForImage(imageName: String, folderNa:String) -> URL?{
        guard let folderURL = getURLForFolder(folderN: folderNa) else {
            return nil
        }
        return folderURL.appendingPathComponent(imageName + ".jpg")
    }
    
    func getURLiCloudForFolder(folderN: String) -> URL? {
        guard let folderURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent(folderN) else {return nil}
        return folderURL
    }
    
    func getURLiCloudForImage(imageName: String, folderNa:String) -> URL?{
        guard let folderURLiCloud = getURLiCloudForFolder(folderN: folderNa) else {
            return nil
        }
        return folderURLiCloud.appendingPathComponent(imageName + ".jpg")
    }
    
    func createiCloudFolder(folderName: String){
        if let iCloudDocumentsURL = getURLiCloudForFolder(folderN: folderName) {
            if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)) {
                do {
                    print("Creation du dossier")
                    try FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    //Error handling
                    print("Error in creating doc")
                }
            }
        }
    }
    
    func saveImage(image: UIImage, nomEvent: String,folderName: String){
        let imageName = getNameImage(nomEvent: nomEvent)
        guard
            let data = image.jpegData(compressionQuality: 5.0),
            let url = getURLForImage(imageName: imageName, folderNa: folderName)
        else { return print("Erreur de conversion ou du path de l'image")}
        
        do{
            print("Fichier sauvegarde")
            try data.write(to: url)
            //saveToiCloud(nomEvent: nomEvent, folderName: folderName)      (1)
            saveToiCloud(nomEvent: imageName, folderName: folderName)
        } catch{
            print("Erreur sauvegarde")
        }
    }
    
    func saveToiCloud(nomEvent: String,folderName: String) {
        
        createiCloudFolder(folderName: folderName)
        //let nom = getNameImage(nomEvent: nomEvent)                        (1)
        let nom = nomEvent
        
        guard let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last?.appendingPathComponent(folderName).appendingPathComponent(nom+".jpg") else { return }
        
        guard let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent(folderName).appendingPathComponent(nom+".jpg") else { return }
        
        var isDir:ObjCBool = false
        print(localDocumentsURL.path)
        print(iCloudDocumentsURL.path)
        if FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: &isDir) {
            do {
                try FileManager.default.removeItem(at: iCloudDocumentsURL)
            }
            catch {
                //Error handling
                print("Error in remove item")
            }
        }
        
        do {
            try FileManager.default.copyItem(at: localDocumentsURL, to: iCloudDocumentsURL)
        }
        catch {
            //Error handling
            print("Error in copy item")
            print(error)
        }
    }
    
}
