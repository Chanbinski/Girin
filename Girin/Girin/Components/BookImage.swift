//
//  BookImage.swift
//  girin
//
//  Created by 박찬빈 on 9/12/22.
//

import Foundation
import SwiftUI

struct BookImage: View {
    
    let image: String
    let width: Double
    let height: Double
    
    var body: some View {
        AsyncImage(url: URL(string: self.image)) { image in
            image
                .resizable()
                .cornerRadius(10)
        } placeholder: {
            Color.gray
        }
        .frame(width: self.width, height: self.height)
        .shadow(
            color: Color.defaultColor.opacity(0.15),
            radius: 3, x: 0, y: 0)
    }
}
