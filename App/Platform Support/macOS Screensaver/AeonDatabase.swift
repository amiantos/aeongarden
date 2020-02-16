//
//  AeonDatabase.swift
//  Aeon Garden Screensaver
//
//  Created by Brad Root on 2/16/20.
//  Copyright © 2020 Brad Root. All rights reserved.
//

import ScreenSaver

struct AeonDatabase {
    fileprivate enum Key {
        static let tank = "aeonTank"
    }

    static var standard: ScreenSaverDefaults {
        guard let bundleIdentifier = Bundle(for: AeonScreenSaverView.self).bundleIdentifier,
        let database = ScreenSaverDefaults(forModuleWithName: bundleIdentifier)
            else { fatalError("Failed to retrieve database!") }

        database.register(defaults: [Key.tank: false])

        return database
    }
}

extension ScreenSaverDefaults {

    func saveTank(_ tank: Tank) {
        if let jsonData = try? JSONEncoder().encode(tank) {
            set(jsonData, for: AeonDatabase.Key.tank)
        }
    }

    func loadTank() -> Tank? {
        if let encodedTank = object(forKey: AeonDatabase.Key.tank) as? Data,
            let loadedTank = try? JSONDecoder().decode(Tank.self, from: encodedTank) {
            return loadedTank
        }
        return nil
    }

}

private extension ScreenSaverDefaults {
    func set(_ object: Any, for key: String) {
        set(object, forKey: key)
        synchronize()
    }
}
