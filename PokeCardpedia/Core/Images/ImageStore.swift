//
//  ImageStore.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/16/23.
//

import Foundation
import CoreData
import SwiftUI

@objc(ImageStored)
public class ImageStored: NSManagedObject {
    lazy var image: Image? = {
        return nil
    }()
}
