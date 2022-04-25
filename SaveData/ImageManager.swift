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
    var camOrFile: Bool = false
    
    /*
    func showPhotoPicker() {
        showPicker = true
    }
    */
     
    //
    init(){}
    
    // Retourne l'image si existante (inutilisee)
    func getImage(imageName: String, folderName:String) -> UIImage? {
        guard let url = getURLForImage(imageName: imageName, folderNa: folderName), FileManager.default.fileExists(atPath: url.path) else {return nil}
        return UIImage(contentsOfFile: url.path)
    }
    
    // Nommage de l'image (Event+Date)
    func getNameImage(nomEvent: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let fileName = dateFormatter.string(from: Date())
        let imageName = nomEvent + "_" + fileName
        return imageName
    }
    
    // Creer un dossier si nécessaire
    func createFolder(folderName: String){
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
    
    // Retourner le PATH du dossier de l'image sur l'iPad
    func getURLForFolder(folderN: String) -> URL? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return nil}
        return url.appendingPathComponent(folderN)
    }
    
    // Retourner le PATH de l'image sur l'iPad
    func getURLForImage(imageName: String, folderNa:String) -> URL?{
        guard let folderURL = getURLForFolder(folderN: folderNa) else {
            return nil
        }
        return folderURL.appendingPathComponent(imageName + ".jpg")
    }
    
    // Retourner le PATH du dossier de l'image sur iCloud
    func getURLiCloudForFolder(folderN: String) -> URL? {
        guard let folderURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent(folderN) else {return nil}
        return folderURL
    }
    
    // Retourner le PATH de l'image sur iCloud
    func getURLiCloudForImage(imageName: String, folderNa:String) -> URL?{
        guard let folderURLiCloud = getURLiCloudForFolder(folderN: folderNa) else {
            return nil
        }
        return folderURLiCloud.appendingPathComponent(imageName + ".jpg")
    }
    // Creer un dossier sur le répertoire iCloud
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
    // Fonction sauvegarder sur l'iPad en physique
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
    
    // Fonction sauvegarder sur iCloud
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
    
    // Match avec une expression régulière sur une String (+ choix du groupe)
    func matches(for re: String, in text: String, groupe: Int) -> Substring {
        do{
            let re = try NSRegularExpression(pattern: re)
            if let match = re.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)){
                if let wholeRange = Range(match.range(at: groupe), in:text){
                    let wholeMatch = text[wholeRange]
                    return wholeMatch
                }
            }
        } catch {
            print("erreur")
            return ""
        }
        return ""
    }
    
    /*
    func camfile(x: Bool){
        self.camorfile = x
    }
    */
}
