//
//  DataController.swift
//  SaveData
//
//  Created by Tino on 24/04/2022.
//

import Foundation
import CoreData

class DataController: ObservableObject{
    let container = NSPersistentContainer(name: "Data")
    init(){
        container.loadPersistentStores { _,error in
            if let error = error {
                print("CoreData erreur")
            }
        }
    }
}
