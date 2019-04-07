//
//  AeonFoodNode.swift
//  Aeon Garden
//
//  Created by Bradley Root on 10/1/17.
//  Copyright © 2017 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SpriteKit

class AeonFoodNode: SKNode, Updatable {
    private var maxLifeTime: Float = 120
    private var lifeTime: Float = 0 {
        didSet {
            if lifeTime >= maxLifeTime {
                die()
            }
        }
    }

    public var interestedCreatures: Int = 0
    internal var lastUpdateTime: TimeInterval = 0

    override init() {
        super.init()

        physicsBody = SKPhysicsBody(circleOfRadius: 8)
        physicsBody?.categoryBitMask = CollisionTypes.food.rawValue
        physicsBody?.collisionBitMask = CollisionTypes.edge.rawValue | CollisionTypes.creature.rawValue | CollisionTypes.ball.rawValue
        physicsBody?.affectedByGravity = false
        physicsBody?.restitution = 1
        physicsBody?.linearDamping = 0.5
        physicsBody?.allowsRotation = true
        physicsBody?.isDynamic = true
        name = "aeonFood"
        zPosition = 1

        let foodBody = SKSpriteNode(imageNamed: "aeonFoodPellet")
        foodBody.size = CGSize(width: 23, height: 33)
        foodBody.zPosition = 1
        foodBody.name = "AeonFoodSprite"
        addChild(foodBody)

        alpha = 0
        let fadeInAction = SKAction.fadeIn(withDuration: 5)
        setScale(0.2)
        let scaleMax = randomCGFloat(min: 0.4, max: 0.7)
        let scaleInAction = SKAction.scale(to: scaleMax, duration: 5)
        let rotateAction = SKAction.rotate(byAngle: 5, duration: TimeInterval(randomCGFloat(min: 3, max: 10)))
        run(SKAction.repeatForever(rotateAction))
        run(SKAction.group([fadeInAction, scaleInAction]), completion: {
            let floatOutAction = SKAction.scale(to: scaleMax / 1.5, duration: 3)
            let floatOutFadeAction = SKAction.fadeAlpha(to: 0.7, duration: 3)
            let floatOutActionGroup = SKAction.group([floatOutAction, floatOutFadeAction])
            floatOutActionGroup.timingMode = .easeInEaseOut
            let floatInAction = SKAction.scale(to: scaleMax, duration: 3)
            let floatInFadeAction = SKAction.fadeAlpha(to: 1, duration: 3)
            let floatInActionGroup = SKAction.group([floatInAction, floatInFadeAction])
            floatInActionGroup.timingMode = .easeInEaseOut
            let floatActionGroup = SKAction.sequence([floatOutActionGroup, floatInActionGroup])
            self.run(SKAction.repeatForever(floatActionGroup))
        })
    }

    func eaten() {
        physicsBody = nil
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.5)
        run(fadeOut, completion: { self.removeFromParent() })
    }

    func eaten(animateTo: CGPoint) {
        physicsBody = nil
        let moveTo = SKAction.move(to: animateTo, duration: 0.5)
        moveTo.timingMode = .easeIn
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.5)
        let actionGroup = SKAction.group([moveTo, fadeOut])
        run(actionGroup, completion: { self.removeFromParent() })
    }

    func die() {
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 5)
        let scaleOutAction = SKAction.scale(to: 0, duration: 5)
        run(SKAction.group([fadeOut, scaleOutAction]), completion: {
            self.removeFromParent()
        })
    }

    func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let deltaTime = currentTime - lastUpdateTime
        let correctedDeltaTime = deltaTime > 1 ? 1 : deltaTime
        if correctedDeltaTime >= 1, lifeTime < maxLifeTime {
            lifeTime += Float(correctedDeltaTime)
            lastUpdateTime = currentTime
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
