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

    func returnLastName() -> String {
        let lastNames: [String] = "Surnames".contentsOrBlank().characters.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        return(lastNames[GKRandomDistribution.init(lowestValue: 0, highestValue: lastNames.count-1).nextInt()])
    }

    func returnFirstName() -> String {
        let firstNames: [String] = "FirstNames".contentsOrBlank().characters.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        return(firstNames[GKRandomDistribution.init(lowestValue: 0, highestValue: firstNames.count-1).nextInt()])
    }

}
