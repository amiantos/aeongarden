//
//  AeonNameGenerator.swift
//  Aeon Garden
//
//  Created by Bradley Root on 10/9/17.
//  Copyright © 2017 Brad Root. All rights reserved.
//

import Foundation
import GameKit

class AeonNameGenerator {
    static let shared = AeonNameGenerator()

    func returnLastName() -> String {
        let lastNames: [String] = "Surnames".contentsOrBlank().split(
            separator: "\n", omittingEmptySubsequences: true
        ).map(String.init)
        return (lastNames[GKRandomDistribution(lowestValue: 0, highestValue: lastNames.count - 1).nextInt()])
    }

    func returnFirstName() -> String {
        let firstNames: [String] = "FirstNames".contentsOrBlank().split(
            separator: "\n", omittingEmptySubsequences: true
        ).map(String.init)
        return (firstNames[GKRandomDistribution(lowestValue: 0, highestValue: firstNames.count - 1).nextInt()])
    }
}
