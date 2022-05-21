//
//  DataController.swift
//  SaveData
//
//  Created by Tino on 24/04/2022.
//
/*
import Foundation
import CoreData
import SwiftUI

class DataController: ObservableObject{
    var pickerType: [String] = ["Document numérique","Tableau blanc","Feuille papier","Carte de visite", "Page de livre","Journal", "Autre"]
    let container : NSPersistentContainer
    init(){
        container = NSPersistentContainer(name: "Data")
        container.loadPersistentStores { _,error in
            if let error = error {
                print("CoreData erreur")
            }
        }
        ForEach(pickerType, id: \.self){ t in
            let ty = Types()
            ty.type = t
            self.addType(type: ty)
            
        }
        
    }
    
    func addType(type: String){
        let t = Types(context: container.viewContext)
        t.type = type
        do{
            try container.viewContext.save()
        } catch {
            print("Erreur Save Type")
        }
    }
    
    func getAllTypes() -> [Types]{
        let fetchReq: NSFetchRequest<Types> = Types.fetchRequest()
        do{
            return try container.viewContext.fetch(fetchReq)
        }catch{
            return []
        }
    }
    
}
*/
