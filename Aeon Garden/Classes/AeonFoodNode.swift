//
//  AeonFoodNode.swift
//  Aeon Garden
//
//  Created by Bradley Root on 10/1/17.
//  Copyright © 2017 Brad Root. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class AeonFoodNode: SKNode {

    private var foodAmount: Int = 100
    public var creaturesInterested: Int = 0
    private var maxLifeTime: Float = 30
    public var lifeTime: Float = 0 {
        didSet {
            if (lifeTime >= maxLifeTime) {
                self.die()
            }
        }
    }

    override init() {
        super.init()

        self.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        self.physicsBody?.categoryBitMask = CollisionTypes.food.rawValue
        self.physicsBody?.collisionBitMask = CollisionTypes.edge.rawValue | CollisionTypes.creature.rawValue
        //self.physicsBody?.contactTestBitMask = CollisionTypes.creature.rawValue
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.restitution = 1
        self.physicsBody?.linearDamping = 0.5
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.isDynamic = true
        self.name = "aeonFood"

        let foodBody = SKSpriteNode(imageNamed: "aeonFoodPellet")
        //foodBody.color = .green
        //foodBody.colorBlendFactor = 1
        foodBody.zPosition = 1
        foodBody.name = "AeonFoodSprite"
        self.addChild(foodBody)

        self.alpha = 0
        let fadeInAction = SKAction.fadeIn(withDuration: 5)
        self.setScale(0.2)
        let scaleMax = randomFloat(min: 0.4, max: 0.7)
        let scaleInAction = SKAction.scale(to: scaleMax, duration: 5)
        let rotateAction = SKAction.rotate(byAngle: 5, duration: TimeInterval(self.randomFloat(min: 3, max: 10)))
        self.run(SKAction.repeatForever(rotateAction))
        self.run(SKAction.group([fadeInAction, scaleInAction]), completion: {
            let floatOutAction = SKAction.scale(to: (scaleMax/1.5), duration: 3)
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

    func bitten() {
        self.foodAmount -= 100
        if self.foodAmount <= 0 {
            self.physicsBody = nil
            let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.5)
            self.run(fadeOut, completion: {self.removeFromParent()})
        }
    }

    func die() {
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 5)
        let scaleOutAction = SKAction.scale(to: 0, duration: 5)
        self.run(SKAction.group([fadeOut, scaleOutAction]), completion: {
            if let mainScene = self.scene as? GameScene {
                mainScene.foodPelletCount = mainScene.foodPelletCount - 1
            }
            self.removeFromParent()

        })
    }

    func randomFloat(min: CGFloat, max: CGFloat) -> CGFloat {
        return (CGFloat(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }

    func age(lastUpdate: TimeInterval) {
        if (lastUpdate < 10 && lifeTime < maxLifeTime) {
            // if state is not sleeping, lose health...
            self.lifeTime = self.lifeTime + Float(lastUpdate)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
