//
//  AeonCameraBodyNode.swift
//  Aeon Garden
//
//  Created by Brad Root on 2/9/20.
//  Copyright © 2020 Brad Root. All rights reserved.
//

import SpriteKit

class AeonCameraBodyNode: SKNode, Updatable {
    var lastUpdateTime: TimeInterval = 0
    var currentTarget: CGPoint?
    var targetingTimer: Timer?
    var targetTimeLimit: TimeInterval = 30
    public var movementSpeed: CGFloat = 8
    public var turnSpeed: CGFloat = 750

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init() {
        super.init()

        physicsBody = SKPhysicsBody(circleOfRadius: 20)
        physicsBody?.categoryBitMask = 0
        physicsBody?.collisionBitMask = 0
        physicsBody?.allowsRotation = true
        physicsBody?.affectedByGravity = false
        physicsBody?.restitution = 0.8
        physicsBody?.friction = 0.1
        physicsBody?.mass = 1
        physicsBody?.linearDamping = 0.5
        physicsBody?.angularDamping = 1
        zPosition = 1

//        let body = SKSpriteNode(texture: foodTexture)
//        body.size = CGSize(width: 40, height: 40)
//        body.zPosition = 1
//        body.name = "AeonCameraBodySprite"
//        addChild(body)
    }

    func update(_ currentTime: TimeInterval) {
        lastUpdateTime = currentTime
        move()
    }

    @objc func pickRandomTarget() {
        if let scene = scene as? AeonTankScene {
            if let randomNode = scene.creatureNodes.randomElement() {
                Log.debug("Picked new target for camera body: \(randomNode.position)")
                currentTarget = randomNode.position

                targetingTimer?.invalidate()

                targetingTimer = Timer.scheduledTimer(
                    timeInterval: targetTimeLimit,
                    target: self,
                    selector: #selector(pickRandomTarget),
                    userInfo: nil,
                    repeats: false
                )
            }
        }
    }

    // MARK: - Movement

    func distance(point: CGPoint) -> CGFloat {
        return CGFloat(hypotf(Float(point.x - position.x), Float(point.y - position.y)))
    }

    func angleBetween(pointOne: CGPoint, andPointTwo pointTwo: CGPoint) -> CGFloat {
        let xdiff = (pointTwo.x - pointOne.x)
        let ydiff = (pointTwo.y - pointOne.y)
        let rad = atan2(ydiff, xdiff)
        return rad - (CGFloat.pi / 2) // convert from atan's right-pointing zero to CG's up-pointing zero
    }

    func move() {
        if let toCGPoint = currentTarget {
            // Thrust
            let radianFactor: CGFloat = CGFloat.pi / 180
            let rotationInDegrees = zRotation / radianFactor
            let newRotationDegrees = rotationInDegrees + 90
            let newRotationRadians = newRotationDegrees * radianFactor

            let thrustVector: CGVector = CGVector(
                dx: cos(newRotationRadians) * movementSpeed,
                dy: sin(newRotationRadians) * movementSpeed
            )

            physicsBody?.applyForce(thrustVector)

            // Rotation
            var goalAngle = angleBetween(pointOne: position, andPointTwo: toCGPoint)
            var creatureAngle = atan2(physicsBody!.velocity.dy, physicsBody!.velocity.dx) - (CGFloat.pi / 2)

            creatureAngle = convertRadiansToPi(creatureAngle)
            goalAngle = convertRadiansToPi(goalAngle)

            let angleDifference = convertRadiansToPi(goalAngle - creatureAngle)
            let angleDivisor: CGFloat = turnSpeed

            physicsBody?.applyTorque(angleDifference / angleDivisor)
        }
    }
}
