//
//  ColorPresetViewModel.swift
//  TheBall
//
//  Created by Toh Kar Le on 1/3/24.
//

import Foundation
import CoreData
import SwiftUI

class ColorPresetViewModel: ObservableObject {
    
    let container: NSPersistentContainer
    
    @Published var savedEntities: [ColorPresetEntity] = []
    
    init() {
        container = NSPersistentContainer(name: "ColorPresentContainer")  // I mispelled Preset but whatever
        container.loadPersistentStores { description, error in
            if let error {
                print("Error loading core data: \(error)")
            } else {
                print("Successfully loaded core data!")
            }
        }
        fetchColorPresets()
    }
    
    func fetchColorPresets() {
        let request = NSFetchRequest<ColorPresetEntity>(entityName: "ColorPresetEntity")
        
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching ColorPresets: \(error.localizedDescription)")
        }
    }
    
    func addColorPreset(id: UUID, name: String, selectedAnimation: String, blur: Double, stickyWall: Bool, stickiness: Double, randomness: Double, moveBallCount: Double, maxBallCount: Double, ballSize: Double, fluidity: Double, setCustomBgColor: Bool, bgColor: Color, setCustomBallColor: Bool, gradient1: Color, gradient2: Color, gradient3: Color) {
        let newColorPreset = ColorPresetEntity(context: container.viewContext)
        newColorPreset.id = id
        newColorPreset.name = name
        newColorPreset.ballSize = ballSize
        newColorPreset.blur = blur
        newColorPreset.fluidity = fluidity
        newColorPreset.maxBallCount = maxBallCount
        newColorPreset.moveBallCount = moveBallCount
        newColorPreset.randomness = randomness
        newColorPreset.selectedAnimation = selectedAnimation
        newColorPreset.setCustomBallColor = setCustomBallColor
        newColorPreset.setCustomBgColor = setCustomBgColor
        newColorPreset.stickiness = stickiness
        newColorPreset.stickyWall = stickyWall
        newColorPreset.bgColor = Int32(bgColor.rawValue)
        newColorPreset.gradient1 = Int32(gradient1.rawValue)
        newColorPreset.gradient2 = Int32(gradient2.rawValue)
        newColorPreset.gradient3 = Int32(gradient3.rawValue)
        
        save()
    }
    
    func save() {
        do {
            try container.viewContext.save()
            fetchColorPresets()
            print("Successfully saved ColorPreset!")
        } catch let error {
            print("Error saving ColorPreset: \(error.localizedDescription)")
        }
    }
    
    func delete(entity: ColorPresetEntity) {
        container.viewContext.delete(entity)
        save()
    }
    
    func delete(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let entity = savedEntities[index]
        container.viewContext.delete(entity)
        save()
    }
}
