//
//  ColorPreset.swift
//  TheBall
//
//  Created by Toh Kar Le on 1/3/24.
//

import Foundation

#if os(iOS)
import UIKit
#endif
#if os(macOS)
import Foundation
#endif

import SwiftUI

struct ColorPreset: Identifiable {
    var id: UUID
    var name: String
    var selectedAnimation: String
    var blur: Double
    var stickyWall: Bool
    var stickiness: Double
    var randomness: Double
    var moveBallCount: Double
    var maxBallCount: Double
    var ballSize: Double
    var fluidity: Double
    var setCustomBgColor: Bool
    var bgColor: Int32
    var setCustomBallColor: Bool
    var gradient1: Int32
    var gradient2: Int32
    var gradient3: Int32
}
