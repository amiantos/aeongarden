//
//  AeonUtils.swift
//  Aeon Garden
//
//  Created by Brad Root on 3/7/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import GameKit

enum State {
    case closed
    case open
}

extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else { return }
        remove(at: index)
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

/// Remove rotation data from radian (e.g. any value above pi is 'switched' to the other side)
func convertRadiansToPi(_ radian: CGFloat) -> CGFloat {
    if radian > CGFloat.pi {
        return radian - 2 * .pi
    } else if radian < -CGFloat.pi {
        return radian + 2 * .pi
    } else {
        return radian
    }
}

func getAverageHue(_ hues: [CGFloat]) -> CGFloat {
    var xAxisHue: CGFloat = 0
    var yAxisHue: CGFloat = 0
    for hue in hues {
        xAxisHue += cos(hue / 180 * CGFloat.pi)
        yAxisHue += sin(hue / 180 * CGFloat.pi)
    }
    yAxisHue /= CGFloat(hues.count)
    xAxisHue /= CGFloat(hues.count)

    var averageHue = round(atan2(yAxisHue, xAxisHue) * 180 / CGFloat.pi)
    if averageHue < 0 {
        averageHue += 360
    }
    return abs(averageHue)
}
