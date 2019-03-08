//
//  AeonCreatureBodyGenerator.swift
//  Aeon Garden
//
//  Created by Brad Root on 3/7/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        brightness = CGFloat(randomInteger(min: 20, max: 100))
        saturation = CGFloat(randomInteger(min: 20, max: 100))
        blend = CGFloat(randomCGFloat(min: 0.3, max: 1))

        let texture = SKTexture(imageNamed: shape.rawValue)
        let color = UIColor(
            hue: self.hue/360,
            saturation: self.saturation/100,
            brightness: self.brightness/100,
            alpha: 1.0)
        super.init(texture: texture, color: color, size: texture.size())
        self.colorBlendFactor = self.blend
        self.zRotation = CGFloat(randomInteger(min: 0, max: 10))
        self.zPosition = 2
    }

}
