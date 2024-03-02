//
//  TheBallApp.swift
//  TheBall
//
//  Created by Toh Kar Le on 24/2/24.
//

import SwiftUI

@main
struct TheBallApp: App {
    
    init() {
        ValueTransformer.setValueTransformer(SerializableColorTransformer(),
                                             forName: NSValueTransformerName(rawValue: "SerializableColorTransformer"))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
