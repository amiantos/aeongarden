//
//  AeonLimbNode.swift
//  Aeon Garden
//
//  Created by Brad Root on 3/7/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SpriteKit

class AeonLimbNode: SKSpriteNode {
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

    init(withLimb limb: AeonLimbNode) {
        shape = limb.shape
        hue = limb.hue
        brightness = limb.brightness
        saturation = limb.saturation
        blend = limb.blend

        super.init(texture: limb.texture, color: limb.color, size: limb.size)
        colorBlendFactor = limb.blend
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
        hue = primaryHue
        brightness = randomCGFloat(min: 0.19, max: 0.67)
        saturation = randomCGFloat(min: 0.84, max: 0.96)
        blend = CGFloat(randomCGFloat(min: 0.8, max: 1))

        let texture = SKTexture(imageNamed: shape.rawValue)
        let color = SKColor(
            hue: hue / 360,
            saturation: saturation,
            brightness: brightness,
            alpha: 1.0
        )
        let limbWidth: Int = randomInteger(min: 10, max: 20)
        super.init(texture: texture, color: color, size: CGSize(width: limbWidth, height: 20))
        colorBlendFactor = blend
        zRotation = CGFloat(randomInteger(min: 0, max: 10))
        zPosition = 2
    }

    public func beginWiggling() {
        let wiggleFactor = randomCGFloat(min: 0, max: 0.2)
        let wiggleAction = SKAction.rotate(
            byAngle: wiggleFactor,
            duration: TimeInterval(randomUniform())
        )
        let wiggleActionBack = SKAction.rotate(
            byAngle: -wiggleFactor,
            duration: TimeInterval(randomUniform())
        )

        let wiggleMoveFactor = randomUniform()
        let wiggleMoveFactor2 = randomUniform()

        let wiggleMovement = SKAction.moveBy(
            x: wiggleMoveFactor,
            y: wiggleMoveFactor2,
            duration: TimeInterval(randomUniform())
        )
        let wiggleMovementBack = SKAction.moveBy(
            x: -wiggleMoveFactor,
            y: -wiggleMoveFactor2,
            duration: TimeInterval(randomUniform())
        )

        let wiggleAround = SKAction.group([wiggleAction, wiggleMovement])
        let wiggleAroundBack = SKAction.group([wiggleActionBack, wiggleMovementBack])

        run(SKAction.repeatForever(SKAction.sequence([wiggleAround, wiggleAroundBack])), withKey: "Wiggling")
    }

    public func endWiggling() {
        removeAllActions()
    }
}
