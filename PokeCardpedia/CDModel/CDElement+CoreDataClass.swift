//
//  CDElement+CoreDataClass.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 6/26/23.
//
//

import Foundation
import CoreData

@objc(CDElement)
public class CDElement: NSManagedObject {
    static func getOfElement(_ element: Element, in context: NSManagedObjectContext, createIfNotFound: Bool = true) -> CDElement? {
        let fetchRequest = CDElement.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", element.rawValue)
        guard let fetched = try? context.fetch(fetchRequest) else { return nil }
        if fetched.count == 1 {
            return fetched[0]
        } else if fetched.count > 1 {
            return nil
        } else {
            guard createIfNotFound else {
                return nil
            }
            let newElement = CDElement(context: context)
            newElement.id = element.rawValue
            if context.saveIfChanged() {
                return newElement
            } else {
                return nil
            }
        }
    }
}
