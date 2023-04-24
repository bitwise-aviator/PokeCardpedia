//
//  DateHandler.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/23/23.
//

import Foundation

extension Date {
    /// Shorthand Gregorian year component.
    var year: Int {
        Calendar(identifier: .gregorian).component(.year, from: self)
    }
}

/// Class wrapping `DateFormatter` instances.
class DateHandler {
    /// Singleton instance.
    static let shared = DateHandler()
    /// Formatter for yyyy/MM/dd date strings.
    let fullYearMonthDay: DateFormatter
    /// Initializes singleton.
    private init() {
        fullYearMonthDay = DateFormatter()
        fullYearMonthDay.dateFormat = "yyyy/MM/dd"
    }
}
