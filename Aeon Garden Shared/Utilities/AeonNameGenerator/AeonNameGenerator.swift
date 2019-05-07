//
//  AeonNameGenerator.swift
//  Aeon Garden
//
//  Created by Bradley Root on 10/9/17.
//  Copyright © 2017 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class AeonNameGenerator {
    static let shared = AeonNameGenerator()

    let firstNames: [String]
    let lastNames: [String]

    init() {
        lastNames = "Surnames".contentsOrBlank().split(
            separator: "\n", omittingEmptySubsequences: true
        ).map(String.init)

        firstNames = "FirstNames".contentsOrBlank().split(
            separator: "\n", omittingEmptySubsequences: true
        ).map(String.init)
    }

    func returnLastName() -> String {
        return (lastNames[randomInteger(min: 0, max: lastNames.count - 1)])
    }

    func returnFirstName() -> String {
        return (firstNames[randomInteger(min: 0, max: firstNames.count - 1)])
    }
}

public extension String {
    func contentsOrBlank() -> String {
        if let path = Bundle(identifier: "net.amiantos.Aeon-Garden")?.path(forResource: self, ofType: nil) {
            do {
                let text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                return text
            } catch { print("Failed to read text from bundle file \(self)") }
        } else { print("Failed to load file from bundle \(self)") }
        return ""
    }
}
