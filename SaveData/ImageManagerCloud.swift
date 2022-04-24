//
//  ImageManagerCloud.swift
//  SaveData
//
//  Created by Tino on 27/03/2022.
//
/*
import Foundation
import SwiftUI
import UIKit

class ImageManagerCloud: ObservableObject{
    
    init(){}

    func createFolder(folderName: String){
        if let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent("ESSAI") {
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
    
    func copyToiCloud(folderN: String) {
        guard let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last else { return }
        
        guard let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else { return }
        
        var isDir:ObjCBool = false
        print(localDocumentsURL)
        print(iCloudDocumentsURL)
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
        }
    }
    
    
}
*/
