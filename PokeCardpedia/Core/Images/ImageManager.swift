//
//  ImageManager.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/16/23.
//

import Foundation
import SwiftUI
import UIKit

class ImageManager {
    static let img = ImageManager()
    enum Error: Swift.Error {
        case fileAlreadyExists
        case invalidDirectory
        case writingFailed
    }
    let fileManager: FileManager
    init(_ fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    func saveImage(_ image: Image) {
        print("image being saved...")
    }
}
