//
//  ImageManager.swift
//  SaveData
//
//  Created by Tino on 25/03/2022.
//

import Foundation
import SwiftUI
import UIKit
import PDFKit
import VisionKit

class ImageManager: ObservableObject{
    
    @Published var showPicker = false
    @Published var uiImg: UIImage?
    var camOrFile: Bool = false
    let rootFolder = "Doc"
    let recentsFiles = "0-RecentsFiles"
     
    //
    init(){}
    
    // Nommage de l'image (Event+Date)
    func getNameImage(nomEvent: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let fileName = dateFormatter.string(from: Date())
        let imageName = nomEvent + "_" + fileName
        return imageName
    }
    
    // Retourner le PATH du dossier de l'image sur l'iPad
    func getURLForFolder(folderN: String, racine: String? = nil) -> URL? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return nil}
        if (racine==nil){
            return url.appendingPathComponent(folderN)
        }
        else{
            return url.appendingPathComponent(racine!).appendingPathComponent(folderN)
        }
    }
    
    // Creer un dossier si nécessaire
    func createFolder(folderName: String, racine: String? = nil){
        guard let url = getURLForFolder(folderN: folderName,racine: racine) else {print("Non");return}
        if !FileManager.default.fileExists(atPath: url.path){
        do{
            try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
        }
            catch {
                print("Error creating directory")
            }
        }
    }
    
    // Retourne l'image si existante (inutilisee)
    func getImage(imageName: String, folderName:String) -> UIImage? {
        guard let url = getURLForImage(imageName: imageName, folderNa: folderName), FileManager.default.fileExists(atPath: url.path) else {return nil}
        return UIImage(contentsOfFile: url.path)
    }
    
    // Retourner le PATH de l'image sur l'iPad
    func getURLForImage(imageName: String, folderNa:String) -> URL?{
        guard let folderURL = getURLForFolder(folderN: folderNa, racine: rootFolder) else {
            return nil
        }
        return folderURL.appendingPathComponent(imageName + ".jpg")
    }
    
    func getURLForImageToPDF(imageName: String, folderNa:String) -> URL?{
        guard let folderURL = getURLForFolder(folderN: folderNa, racine: rootFolder) else {
            return nil
        }
        return folderURL.appendingPathComponent(imageName + ".pdf")
    }
    func getURLForImageToPDFinRecent(imageName: String) -> URL?{
        guard let folderURL = getURLForFolder(folderN: recentsFiles) else {
            return nil
        }
        return folderURL.appendingPathComponent(imageName + ".pdf")
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
            saveToiCloud(nomEvent: imageName, folderName: folderName, format: "jpg")
        } catch{
            print("Erreur sauvegarde")
        }
    }
    
    // Fonction sauvegarder sur iCloud
    func saveToiCloud(nomEvent: String,folderName: String, format: String) {
        
        //createiCloudFolder(folderName: folderName)
        
        //let nom = getNameImage(nomEvent: nomEvent)                        (1)
        
        guard let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last?.appendingPathComponent(rootFolder).appendingPathComponent(folderName).appendingPathComponent(nomEvent+"."+format) else { return }
        
        //guard let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent(folderName).appendingPathComponent(nom+"."+format) else { return }
        
        guard let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent(folderName+"-"+nomEvent+"."+format) else { return }
        
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
    
    func transformToPDF(images: [UIImage]) -> PDFDocument {
        let pdfDocument = PDFDocument()
        for i in images.indices{
            let pdfPage = PDFPage(image: images[i])
            pdfDocument.insert(pdfPage!, at: i)
        }
        return pdfDocument
    }
    
    func pdfToImage(document: CGPDFDocument ,index: Int) -> UIImage{
        let page = document.page(at: index)
        let pageRect = page!.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            ctx.cgContext.drawPDFPage(page!)
        }
        return img
    }
    
    func pdfToImages(url: URL) -> [UIImage]? {
        var images:[UIImage] = []
        guard let document = CGPDFDocument(url as CFURL) else {return nil}
        for i in 1...(document.numberOfPages){
            images.insert(pdfToImage(document: document, index: i), at: i-1)
        }
        return images
    }
    
    func saveAsPDF(images: [UIImage], nomEvent: String, folderName: String){
        createFolder(folderName: recentsFiles)
        createFolder(folderName: folderName, racine: rootFolder)
        let imageName = getNameImage(nomEvent: nomEvent)
        let pdfDocument = transformToPDF(images: images)
        let data = pdfDocument.dataRepresentation()
        let url = getURLForImageToPDF(imageName: imageName, folderNa: folderName)
        let recentsURL = getURLForImageToPDFinRecent(imageName: folderName+"-"+imageName)
        print("Fichier sauvegarde")
        do {
            try data!.write(to: url!)
            try data!.write(to: recentsURL!)
            saveToiCloud(nomEvent: imageName, folderName: folderName, format: "pdf")
        }
        catch {
            print("Erreur PDF")
        }
    }
}
