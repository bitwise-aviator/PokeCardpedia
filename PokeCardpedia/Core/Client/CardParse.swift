//
//  CardParse.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/13/23.
//

import Foundation

typealias SetDictByYear = [Int: [SetFromJson]]

enum SetOrder {
    case releaseDate
}

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
            return nil
        }

        return prettyPrintedString
    }
}

///
/// JSON card results root.
///
struct CardJsonData: Codable {
    let data: [CardFromJson]
}

struct CardJsonDataSingle: Codable {
    let data: CardFromJson
}

struct SetJsonData: Codable {
    let data: [SetFromJson]
}

struct SetJsonDataSingle: Codable {
    let data: SetFromJson
}

struct SetFromJson: Codable, Hashable {
    static func == (lhs: SetFromJson, rhs: SetFromJson) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    let id: String
    let name: String
    let series: String
    let images: SetImagePath
    let releaseDate: String
    var releasedOn: Date {
        return DateHandler.shared.fullYearMonthDay.date(from: releaseDate) ??
        DateHandler.shared.fullYearMonthDay.date(from: "1970/01/01")!
    }
}

extension [SetFromJson] {
    var releaseYears: [Int] {
        var resultSet = Set<Int>()
        for elem in self {
            resultSet.insert(elem.releasedOn.year)
        }
        return [Int](resultSet).sorted()
    }
    var groupedByYear: SetDictByYear {
        var dict = SetDictByYear()
        for elem in self {
            if dict[elem.releasedOn.year] == nil {
                dict[elem.releasedOn.year] = [elem]
            } else {
                dict[elem.releasedOn.year]?.append(elem)
            }
        }
        return dict
    }
}

/// Auto-decooded struct from API response
struct CardFromJson: Codable {
    let id: String
    let set: SetFromJson
    let number: String
    let name: String
    let rarity: String?
    let supertype: String
    let types: [String]?
    let subtypes: [String]?
    let evolvesFrom: String?
    // Disabling swiftlint check below, struct properties must match JSON keys.
    let hp: String? // swiftlint:disable:this identifier_name
    let images: CardImagePath
    let nationalPokedexNumbers: [Int]?
    var sortId: String {
        let match = number.firstMatch(of: Card.sortRegex)
        let setId = set.id
        guard let match else {return "\(setId)-\(number)"}
        let formattedNumber = String(format: "%03d", Int(match.output.number)!)
        return String("\(setId)-\(match.output.prefix)\(formattedNumber)\(match.output.suffix)")
    }
    func toCardObject() -> Card {
        return Card(from: self)
    }
}

struct SetImagePath: Codable {
    let logo: String
    let symbol: String
}

struct CardImagePath: Codable {
    let small: String
    let large: String
}

/// Stores URLs for a `Card`'s remote image data.
struct CardImageUrl: Hashable {
    /// Path for small (thumbnail) size image.
    let small: URL?
    /// Path for large (detail) size image.
    let large: URL?
    /// Checks if two CardImageUrl instances are memberwise equal.
    /// - Parameters:
    ///   - lhs: a CardImageUrl instance
    ///   - rhs: another CardImageUrl instance
    /// - Returns: true if both small & large URLs are equal, else false.
    static func == (lhs: CardImageUrl, rhs: CardImageUrl) -> Bool {
        lhs.small == rhs.small && lhs.large == rhs.large
    }
    /// Creates hashable conformance.
    /// - Parameter hasher: storage for the struct's hash value.
    func hash(into hasher: inout Hasher) {
        hasher.combine(small)
    }
    /// Convenience initializer from API response JSON.
    /// - Parameter pathObject: source from JSON structure.
    init(pathObject: CardImagePath) {
        self.init(small: URL(string: pathObject.small),
                  large: URL(string: pathObject.large))
    }
    /// Memberwise initialization.
    /// - Parameters:
    ///   - smallUrl: URL for small (thumbnail) size image.
    ///   - largeUrl: URL for large (detail) size image.
    init(small smallUrl: URL?, large largeUrl: URL?) {
        small = smallUrl
        large = largeUrl
    }
}

func parseSetsFromJson(data: Data?, orderBy: SetOrder = .releaseDate) -> [SetFromJson]? {
    do {
        guard let data else {return nil}
        let decoder = JSONDecoder()
        let jsonStruct: SetJsonData?
        // print(data.prettyPrintedJSONString ?? "")
        let jsonMultipleOutput = try? decoder.decode(SetJsonData.self, from: data)
        if let jsonMultipleOutput {
            jsonStruct = jsonMultipleOutput
        } else {
            let jsonSingleOutput = try decoder.decode(SetJsonDataSingle.self, from: data)
            jsonStruct = SetJsonData(data: [jsonSingleOutput.data])
        }
        guard let jsonStruct else {return nil}
        var structedData = jsonStruct.data
        if orderBy == .releaseDate {
            structedData.sort(by: {$0.releasedOn < $1.releasedOn})
        }
        return structedData
        /*guard jsonStruct.data.count > 0 else {return nil}
        // print(jsonStruct.data[0])
        print(jsonStruct.data.map {"\($0.name) \($0.series)"} )
        return jsonStruct.data.map {URL(string: $0.images.symbol)}*/
    } catch {
        print(error)
        return nil
    }
}

func parseCardsFromJson(data: Data) -> [CardFromJson]? {
    do {
        let decoder = JSONDecoder()
        let jsonStruct: CardJsonData?
        // print(data.prettyPrintedJSONString ?? "")
        let jsonMultipleOutput = try? decoder.decode(CardJsonData.self, from: data)
        if let jsonMultipleOutput {
            jsonStruct = jsonMultipleOutput
        } else {
            let jsonSingleOutput = try decoder.decode(CardJsonDataSingle.self, from: data)
            jsonStruct = CardJsonData(data: [jsonSingleOutput.data])
        }
        guard let jsonStruct else {return nil}
        return jsonStruct.data
        /*guard jsonStruct.data.count > 0 else {return nil}
        // print(jsonStruct.data[0])
        return jsonStruct.data.map { CardImageUrl(pathObject: $0.images)}*/
    } catch {
        print(error)
        return nil
    }
}

func parseCardsFromJson(data: [Data]) -> [CardFromJson]? {
    var results = [CardFromJson]()
    // print(data.prettyPrintedJSONString ?? "")
    for item in data {
        guard let parsed = parseCardsFromJson(data: item) else {return nil}
        results += parsed
    }
    return results
}
