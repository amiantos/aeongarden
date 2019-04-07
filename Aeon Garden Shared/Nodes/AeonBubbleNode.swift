//
//  AeonBubbleNode.swift
//  Aeon Garden
//
//  Created by Bradley Root on 3/24/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import SpriteKit

class AeonBubbleNode: SKNode, Updatable {
    private var maxLifeTime: Float = 25
    private var lifeTime: Float = 0 {
        didSet {
            if lifeTime >= maxLifeTime {
                die()
            }
        }
    }
    internal var lastUpdateTime: TimeInterval = 0

    override init() {
        super.init()

        physicsBody = SKPhysicsBody(circleOfRadius: 16)
        physicsBody?.categoryBitMask = CollisionTypes.ball.rawValue
        physicsBody?.contactTestBitMask =  CollisionTypes.edge.rawValue | CollisionTypes.creature.rawValue
        physicsBody?.allowsRotation = true
        physicsBody?.affectedByGravity = false
        physicsBody?.restitution = 0.2
        physicsBody?.linearDamping = 0.2
        physicsBody?.angularDamping = 0.2
        name = "aeonBall"
        zPosition = 1

        let ballColor = SKShapeNode(circleOfRadius: 16)
        ballColor.fillColor = SKColor(hue: 0.5472, saturation: 1, brightness: 0.68, alpha: 1) /* #007cad */
        ballColor.strokeColor = .clear
        ballColor.zPosition = 1
        addChild(ballColor)

        alpha = 0
        let fadeMax = randomCGFloat(min: 0.2, max: 0.5)
        let fadeInAction = SKAction.fadeAlpha(to: fadeMax, duration: 10)
        setScale(0.2)
        let scaleMax = randomCGFloat(min: 0.4, max: 0.8)
        let scaleInAction = SKAction.scale(to: scaleMax, duration: 10)
        run(SKAction.group([fadeInAction, scaleInAction]))

        let floatUp = SKAction.moveBy(x: 0, y: randomCGFloat(min: 1, max: 3), duration: 0.2)
        run(SKAction.repeatForever(floatUp))

        let shiftLeft = SKAction.moveBy(x: 8, y: 0, duration: 2)
        shiftLeft.timingMode = .easeInEaseOut
        let shiftRight = SKAction.moveBy(x: -16, y: 0, duration: 4)
        shiftRight.timingMode = .easeInEaseOut
        let shiftSequence = SKAction.sequence([shiftLeft, shiftRight])
        run(SKAction.repeatForever(shiftSequence))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let deltaTime = currentTime - lastUpdateTime
        if deltaTime >= 1, lifeTime < maxLifeTime {
            lifeTime += Float(deltaTime)
            lastUpdateTime = currentTime
        }
    }

    func die() {
        physicsBody = nil
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 5)
        let scaleOutAction = SKAction.scale(to: 1.5, duration: 5)
        run(SKAction.group([fadeOut, scaleOutAction]), completion: {
            self.removeFromParent()
        })
    }

    func dieQuick() {
        AeonSoundManager.shared.play(.bubblePop, onNode: self)
        physicsBody = nil
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.1)
        let scaleOutAction = SKAction.scale(to: 1, duration: 0.1)
        run(SKAction.group([fadeOut, scaleOutAction]), completion: {
            self.removeFromParent()
        })
    }
}
