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
    let shape: BodyPart
    let hue: CGFloat
    let blend: CGFloat
    let brightness: CGFloat
    let saturation: CGFloat
    let limbWidth: Int

    let wiggleFactor: CGFloat
    let wiggleMoveFactor: CGFloat
    let wiggleMoveBackFactor: CGFloat
    let wiggleActionDuration: TimeInterval
    let wiggleActionBackDuration: TimeInterval
    let wiggleActionMovementDuration: TimeInterval
    let wiggleActionMovementBackDuration: TimeInterval

    let limbzRotation: CGFloat

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(with limbStruct: Limb) {
        shape = limbStruct.shape
        hue = CGFloat(limbStruct.hue)
        brightness = CGFloat(limbStruct.brightness)
        saturation = CGFloat(limbStruct.saturation)
        blend = CGFloat(limbStruct.blend)

        limbWidth = limbStruct.limbWidth
        limbzRotation = CGFloat(limbStruct.limbzRotation)

        wiggleFactor = CGFloat(limbStruct.wiggleFactor)
        wiggleMoveFactor = CGFloat(limbStruct.wiggleMoveFactor)
        wiggleMoveBackFactor = CGFloat(limbStruct.wiggleMoveBackFactor)
        wiggleActionDuration = TimeInterval(limbStruct.wiggleActionDuration)
        wiggleActionBackDuration = TimeInterval(limbStruct.wiggleActionBackDuration)
        wiggleActionMovementDuration = TimeInterval(limbStruct.wiggleActionMovementDuration)
        wiggleActionMovementBackDuration = TimeInterval(limbStruct.wiggleActionMovementDuration)

        var texture = triangleTexture
        switch limbStruct.shape {
        case .circle:
            texture = circleTexture
        case .square:
            texture = squareTexture
        default:
            break
        }

        let color = SKColor(
            hue: CGFloat(limbStruct.hue / 360),
            saturation: CGFloat(limbStruct.saturation),
            brightness: CGFloat(limbStruct.brightness),
            alpha: 1.0
        )
        super.init(texture: texture, color: color, size: CGSize(width: limbStruct.limbWidth, height: 20))
        colorBlendFactor = blend
        zRotation = limbzRotation
        zPosition = 2
    }

    init(withLimb limb: AeonLimbNode) {
        shape = limb.shape
        hue = limb.hue
        brightness = limb.brightness
        saturation = limb.saturation
        blend = limb.blend

        limbWidth = limb.limbWidth
        limbzRotation = limb.limbzRotation

        wiggleFactor = randomCGFloat(min: 0, max: 0.2)
        wiggleMoveFactor = randomUniform()
        wiggleMoveBackFactor = randomUniform()
        wiggleActionDuration = TimeInterval(randomUniform())
        wiggleActionBackDuration = TimeInterval(randomUniform())
        wiggleActionMovementDuration = TimeInterval(randomUniform())
        wiggleActionMovementBackDuration = TimeInterval(randomUniform())

        super.init(texture: limb.texture, color: limb.color, size: limb.size)
        colorBlendFactor = blend
        zRotation = limbzRotation
        zPosition = 2
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

        limbWidth = randomInteger(min: 10, max: 20)
        limbzRotation = CGFloat(randomInteger(min: 0, max: 10))

        wiggleFactor = randomCGFloat(min: 0, max: 0.2)
        wiggleMoveFactor = randomUniform()
        wiggleMoveBackFactor = randomUniform()
        wiggleActionDuration = TimeInterval(randomUniform())
        wiggleActionBackDuration = TimeInterval(randomUniform())
        wiggleActionMovementDuration = TimeInterval(randomUniform())
        wiggleActionMovementBackDuration = TimeInterval(randomUniform())

        var texture = triangleTexture
        switch shape {
        case .circle:
            texture = circleTexture
        case .square:
            texture = squareTexture
        default:
            break
        }

        let color = SKColor(
            hue: hue / 360,
            saturation: saturation,
            brightness: brightness,
            alpha: 1.0
        )
        super.init(texture: texture, color: color, size: CGSize(width: limbWidth, height: 20))
        colorBlendFactor = blend
        zRotation = limbzRotation
        zPosition = 2
    }

    public func beginWiggling() {
        let wiggleAction = SKAction.rotate(
            byAngle: wiggleFactor,
            duration: wiggleActionDuration
        )
        let wiggleActionBack = SKAction.rotate(
            byAngle: -wiggleFactor,
            duration: wiggleActionBackDuration
        )

        let wiggleMovement = SKAction.moveBy(
            x: wiggleMoveFactor,
            y: wiggleMoveBackFactor,
            duration: wiggleActionMovementDuration
        )
        let wiggleMovementBack = SKAction.moveBy(
            x: -wiggleMoveFactor,
            y: -wiggleMoveBackFactor,
            duration: wiggleActionMovementBackDuration
        )

        let wiggleAround = SKAction.group([wiggleAction, wiggleMovement])
        let wiggleAroundBack = SKAction.group([wiggleActionBack, wiggleMovementBack])

        run(SKAction.repeatForever(SKAction.sequence([wiggleAround, wiggleAroundBack])), withKey: "Wiggling")
    }

    public func endWiggling() {
        removeAllActions()
    }
}
