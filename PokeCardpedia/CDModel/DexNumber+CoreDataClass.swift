//
//  DexNumber+CoreDataClass.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 6/26/23.
//
//

import Foundation
import CoreData

@objc(DexNumber)
public class DexNumber: NSManagedObject {
    static func getByNumber(_ iNumber: Int, in context: NSManagedObjectContext, createIfNotFound: Bool = true) -> DexNumber? {
        let number = Int64(iNumber)
        let fetchRequest = DexNumber.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %d", number)
        guard let fetched = try? context.fetch(fetchRequest) else { return nil }
        if fetched.count == 1 {
            return fetched[0]
        } else if fetched.count > 1 {
            return nil
        } else {
            guard createIfNotFound else {
                return nil
            }
            let newElement = DexNumber(context: context)
            newElement.id = number
            if context.saveIfChanged() {
                return newElement
            } else {
                return nil
            }
        }
    }
}
