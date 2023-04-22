//
//  ImageIO.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/16/23.
//

import Foundation
import UIKit
import SwiftUI

extension URLCache {
    static let imageCache = URLCache.shared
    // static let imageCache = URLCache(memoryCapacity: 512*1024*1024, diskCapacity: 10*1024*1024*1024)
}

extension Image {
    init?(data: Data) {
        if let uiImage = UIImage(data: data) {
            self.init(uiImage: uiImage)
        } else {
            return nil
        }
    }
}
