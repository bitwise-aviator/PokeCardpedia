//
//  CoreSettings.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/13/23.
//

import Foundation

class CoreSettings: ObservableObject {
    static var settings = CoreSettings()
    @Published var trainerName: String = ""
    var userNamePossessive: String {
        if trainerName.isEmpty {
            return "My"
        } else if trainerName.uppercased().hasSuffix("S") {
            return trainerName + "'"
        } else {
            return trainerName + "'s"
        }
    }
    func getTrainerName() {
        guard let newTrainerName = UserDefaults.standard.string(forKey: "trainer_name") else {
            trainerName = ""
            return
        }
        trainerName = newTrainerName
    }
    func setTrainerName(target: String) {
        UserDefaults.standard.set(target, forKey: "trainer_name")
        getAll()
    }
    func getAll() {
        getTrainerName()
    }
    private init() {
        getAll()
    }
}
