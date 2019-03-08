//
//  Utils.swift
//  Aeon Garden
//
//  Created by Brad Root on 3/7/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation
import GameKit


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

func randomInteger(min: Int, max: Int) -> Int {
    return GKRandomDistribution(lowestValue: min, highestValue: max).nextInt()
}

func randomCGFloat(min: CGFloat, max: CGFloat) -> CGFloat {
    return (CGFloat(arc4random()) / 0xFFFFFFFF) * (max - min) + min
}
