//
//  AeonBallNode.swift
//  Aeon Garden
//
//  Created by Bradley Root on 3/24/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import SpriteKit

class AeonBallNode: SKNode, Updatable {
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
        physicsBody?.collisionBitMask = CollisionTypes.edge.rawValue | CollisionTypes.creature.rawValue | CollisionTypes.food.rawValue | CollisionTypes.ball.rawValue
        physicsBody?.contactTestBitMask = CollisionTypes.creature.rawValue | CollisionTypes.edge.rawValue
        physicsBody?.allowsRotation = true
        physicsBody?.affectedByGravity = false
        physicsBody?.restitution = 0.2
        physicsBody?.linearDamping = 0.2
        physicsBody?.angularDamping = 0.2
        name = "aeonBall"
        zPosition = 1

        let ballColor = SKShapeNode(circleOfRadius: 16)
        ballColor.fillColor = UIColor(hue: 0.5472, saturation: 1, brightness: 0.68, alpha: 0.4) /* #007cad */
        ballColor.strokeColor = .clear
        ballColor.zPosition = 1
        addChild(ballColor)

        alpha = 0
        let fadeInAction = SKAction.fadeIn(withDuration: 10)
        setScale(0.2)
        let scaleMax = randomCGFloat(min: 0.4, max: 0.8)
        let scaleInAction = SKAction.scale(to: scaleMax, duration: 10)
        run(SKAction.group([fadeInAction, scaleInAction]))

        let floatUp = SKAction.moveBy(x: 0, y: 2, duration: 0.2)
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
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 10)
        let scaleOutAction = SKAction.scale(to: 0, duration: 10)
        run(SKAction.group([fadeOut, scaleOutAction]), completion: {
            self.removeFromParent()
        })
    }

    func dieQuick() {
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.2)
        let scaleOutAction = SKAction.scale(to: 0, duration: 0.2)
        run(SKAction.group([fadeOut, scaleOutAction]), completion: {
            self.removeFromParent()
        })
    }
}
