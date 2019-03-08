//
//  AeonCreatureBodyGenerator.swift
//  Aeon Garden
//
//  Created by Brad Root on 3/7/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation
import GameKit
import SpriteKit

class AeonCreatureLimb: SKSpriteNode {
    public var shape: BodyPart
    public var hue: CGFloat
    public var blend: CGFloat
    public var brightness: CGFloat
    public var saturation: CGFloat

    public enum BodyPart: String {
        case triangle = "aeonTriangle"
        case circle = "aeonCircle"
        case square = "aeonSquare"
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(withLimb limb: AeonCreatureLimb) {
        shape = limb.shape
        hue = limb.hue * randomCGFloat(min: 0.8, max: 1.2)
        brightness = limb.brightness * randomCGFloat(min: 0.8, max: 1.2)
        saturation = limb.saturation * randomCGFloat(min: 0.8, max: 1.2)
        blend = limb.blend * randomCGFloat(min: 0.8, max: 1.2)
        let color = UIColor(
            hue: hue,
            saturation: saturation,
            brightness: brightness,
            alpha: 1.0
        )

        super.init(texture: limb.texture, color: color, size: limb.size)
        colorBlendFactor = blend
        zRotation = limb.zRotation
        zPosition = limb.zPosition
    }

    init(withPrimaryHue primaryHue: CGFloat) {
        let randomInt: Int = randomInteger(min: 0, max: 2)
        shape = {
            switch randomInt {
            case 0:
                return .circle
            case 1:
                return .square
            default:
                return .triangle
            }
        }()
        hue = primaryHue + CGFloat(randomInteger(min: -20, max: 20))
        brightness = CGFloat(randomInteger(min: 50, max: 100))
        saturation = CGFloat(randomInteger(min: 50, max: 100))
        blend = CGFloat(randomCGFloat(min: 0.3, max: 1))

        let texture = SKTexture(imageNamed: shape.rawValue)
        let color = UIColor(
            hue: hue / 360,
            saturation: saturation / 100,
            brightness: brightness / 100,
            alpha: 1.0
        )
        super.init(texture: texture, color: color, size: texture.size())
        colorBlendFactor = blend
        zRotation = CGFloat(randomInteger(min: 0, max: 10))
        zPosition = 2
    }
}
