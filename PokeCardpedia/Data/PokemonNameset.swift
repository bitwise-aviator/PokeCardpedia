//
//  PokemonNameset.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/22/23.
//

import Foundation
import SwiftCSV

class PokemonNameset {
    static let common = PokemonNameset()
    static let languageKeys = ["en", "es", "it", "de", "fr", "zh", "zh_Hant_HK", "ko", "ja"]
    var data: [Int: [String: String]]
    func getLocalizedName(id: Int) -> String? {
        guard let names = data[id] else { return nil }
        // Start with preferred languages in app.
        for locale in Locale.preferredLanguages {
            if let name = names[locale] {
                return name
            }
            for key in PokemonNameset.languageKeys {
                if locale.hasPrefix(key), let name = names[key] {
                    return name
                }
            }
        }
        return names["en"]
    }
    init() {
        print(Locale.preferredLanguages)
        data = [:]
        guard let path = Bundle.main.url(forResource: "pokemon_names", withExtension: "csv") else {
            return
        }
        let source = try? CSV<Named>(url: path, delimiter: .comma)
        if let source {
            for row in source.rows {
                guard let key = Int(row["keys"] ?? "") else {continue}
                data[key] = [
                    "en": row["en"] ?? "",
                    "es": row["es"] ?? "",
                    "it": row["it"] ?? "",
                    "de": row["de"] ?? "",
                    "fr": row["fr"] ?? "",
                    "zh_Hant_HK": row["zh_HK"] ?? "",
                    "zh": row["zh"] ?? "",
                    "ko": row["ko"] ?? "",
                    "ja": row["ja"] ?? ""
                ]
            }
        }
    }
}
