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
        let t:[String] = "Surnames".contentsOrBlank().characters.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        return(t[GKRandomDistribution.init(lowestValue: 0, highestValue: t.count-1).nextInt()])
    }
    
    func returnFirstName() -> String {
        let t:[String] = "FirstNames".contentsOrBlank().characters.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        return(t[GKRandomDistribution.init(lowestValue: 0, highestValue: t.count-1).nextInt()])
    }
    
    
}
