//
//  SaveDataApp.swift
//  SaveData
//
//  Created by Tino on 21/03/2022.
//

import SwiftUI

@main
struct SaveDataApp: App {
    @StateObject var vm = ImageManager()
    //@StateObject var vm2 = ImageManagerCloud()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                //.environmentObject(vm2)
        }
    }
}


