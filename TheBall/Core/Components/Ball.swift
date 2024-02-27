//
//  Ball.swift
//  TheBall
//
//  Created by Toh Kar Le on 25/2/24.
//

import SwiftUI

struct Ball: View {
    
    var cornerRadius: CGFloat = 99
    var width: CGFloat = 150
    var offset: CGSize = .zero
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.white)
            .frame(width: width, height: width)
            .offset(offset)
    }
}

#Preview {
    Ball()
}
