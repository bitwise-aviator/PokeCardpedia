//
//  CardParse.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/13/23.
//

import Foundation

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
}

struct CardFromJson: Codable {
    let id: String
    let set: SetFromJson
    let name: String
    let number: String
    let supertype: String
    let types: [String]?
    let subtypes: [String]?
    let images: CardImagePath
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

struct CardImageUrl: Hashable {
    let small: URL?
    let large: URL?
    static func == (lhs: CardImageUrl, rhs: CardImageUrl) -> Bool {
        lhs.small == rhs.small
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(small)
    }
    init(pathObject: CardImagePath) {
        small = URL(string: pathObject.small)
        large = URL(string: pathObject.large)
    }
    init(small smallUrl: URL?, large largeUrl: URL?) {
        small = smallUrl
        large = largeUrl
    }
}

func parseSetsFromJson(data: Data?) -> [SetFromJson]? {
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
        return jsonStruct.data
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
