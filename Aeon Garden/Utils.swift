//
//  Utils.swift
//  Aeon Garden
//
//  Created by Brad Root on 3/7/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation
import GameKit

protocol Updatable {
    func update(_ currentTime: TimeInterval)
    var lastUpdateTime: TimeInterval { get set }
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

func toTimestamp(timeInterval: TimeInterval) -> String {
    let totalSeconds: Float = Float(timeInterval)
    let hours = Int(totalSeconds / 3600)
    let minutes = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
    let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))

    return """
    \(String(format: "%02d", hours)):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))
    """
}

func randomInteger(min: Int, max: Int) -> Int {
    return GKRandomDistribution(lowestValue: min, highestValue: max).nextInt()
}

func randomBool() -> Bool {
    return GKRandomSource.sharedRandom().nextBool()
}

func randomUniform() -> CGFloat {
    return randomCGFloat(min: 0, max: 1)
}

func randomCGFloat(min: CGFloat, max: CGFloat) -> CGFloat {
    return CGFloat(Float.random(in: Float(min) ... Float(max)))
}
