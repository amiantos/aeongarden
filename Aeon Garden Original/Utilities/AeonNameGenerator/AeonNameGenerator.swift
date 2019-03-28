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

    func returnLastName() -> String {
        let lastNames: [String] = "Surnames".contentsOrBlank().split(
            separator: "\n", omittingEmptySubsequences: true
        ).map(String.init)
        return (lastNames[randomInteger(min: 0, max: lastNames.count - 1)])
    }

    func returnFirstName() -> String {
        let firstNames: [String] = "FirstNames".contentsOrBlank().split(
            separator: "\n", omittingEmptySubsequences: true
        ).map(String.init)
        return (firstNames[randomInteger(min: 0, max: firstNames.count - 1)])
    }
}

public extension String {
    func contentsOrBlank() -> String {
        if let path = Bundle.main.path(forResource: self, ofType: nil) {
            do {
                let text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                return text
            } catch { print("Failed to read text from bundle file \(self)") }
        } else { print("Failed to load file from bundle \(self)") }
        return ""
    }
}
