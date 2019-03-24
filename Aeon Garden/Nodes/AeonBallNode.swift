//
//  AeonBallNode.swift
//  Aeon Garden
//
//  Created by Bradley Root on 3/24/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import SpriteKit

class AeonBallNode: SKNode {

    override init() {
        super.init()

        physicsBody = SKPhysicsBody(circleOfRadius: 17)
        physicsBody?.categoryBitMask = CollisionTypes.ball.rawValue
        physicsBody?.collisionBitMask = CollisionTypes.edge.rawValue | CollisionTypes.creature.rawValue | CollisionTypes.food.rawValue | CollisionTypes.ball.rawValue
        physicsBody?.affectedByGravity = false
        physicsBody?.restitution = 0.2
        physicsBody?.linearDamping = 0.3
        physicsBody?.angularDamping = 0.1
        name = "aeonBall"
        zPosition = 1

        let ballColor = SKShapeNode(circleOfRadius: 17)
        ballColor.fillColor = .white
        ballColor.zPosition = 1
        addChild(ballColor)

        let ballBody = SKSpriteNode(imageNamed: "aeonBall")
        ballBody.size = CGSize(width: 30, height: 30)
        ballBody.zPosition = 2
        ballBody.name = "AeonBallSprite"
        addChild(ballBody)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
