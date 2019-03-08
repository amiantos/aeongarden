//
//  aeonCreatureNode.swift
//  Aeon Garden
//
//  Created by Bradley Root on 9/30/17.
//  Copyright © 2017 Brad Root. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit
import UIKit

class AeonCreatureNode: SKNode {
    // MARK: - Creature Names

    public let firstName: String
    public let lastName: String
    public var fullName: String {
        return "\(firstName) \(lastName)"
    }

    public var parentNames: [String] = []

    // MARK: - Inheritable Traits

    private var limbOne: AeonCreatureLimb
    private var limbTwo: AeonCreatureLimb
    private var limbThree: AeonCreatureLimb
    private var limbFour: AeonCreatureLimb

    public var movementSpeed: CGFloat = 1
    public var sizeModififer: CGFloat = 1

    public var currentState: State = State.nothing
    public var currentHealth: Float = Float(GKRandomDistribution(lowestValue: 100, highestValue: 250).nextInt()) {
        didSet {
            if currentHealth <= 0 {
                die()
            } else if currentHealth > 300 {
                currentHealth = 300
            }
        }
    }

    public var currentFoodTarget: AeonFoodNode?
    public var currentLoveTarget: AeonCreatureNode?
    public var currentMoveTarget: CGPoint?

    private var lifeState: Bool = true
    public var lifeTime: Float = 0

    private var lastThinkTime: TimeInterval = 0

    public enum State: String {
        case nothing = "Thinking"
        case randomMovement = "Wandering"
        case locatingFood = "Locating Food"
        case movingToFood = "Approaching Food"
        case locatingLove = "Looking for Love"
        case movingToLove = "Chasing Love"
        case dead = "Dying"
    }

    override init() {
        // Set primary hue for initial creatures...
        let primaryHue = CGFloat(GKRandomDistribution(lowestValue: 1, highestValue: 365).nextInt())

        firstName = AeonNameGenerator.shared.returnFirstName()
        lastName = AeonNameGenerator.shared.returnLastName()

        // Create limbs
        limbOne = AeonCreatureLimb(withPrimaryHue: primaryHue)
        limbTwo = AeonCreatureLimb(withPrimaryHue: primaryHue)
        limbThree = AeonCreatureLimb(withPrimaryHue: primaryHue)
        limbFour = AeonCreatureLimb(withPrimaryHue: primaryHue)

        super.init()

        movementSpeed = randomFloat(min: 5, max: 10)
        sizeModififer = randomFloat(min: 0.7, max: 1.5)

        setupLimbs()

        setupBodyPhysics()
    }

    init(withParents parents: [AeonCreatureNode]) {
        if parents.count < 2 {
            fatalError("Virgin births are not allowed.")
        }

        firstName = AeonNameGenerator.shared.returnFirstName()
        lastName = parents.randomElement()!.lastName

        parentNames.append(parents[0].lastName)
        parentNames.append(parents[1].lastName)

        limbOne = AeonCreatureLimb(withLimb: parents.randomElement()!.limbOne)
        limbTwo = AeonCreatureLimb(withLimb: parents.randomElement()!.limbTwo)
        limbThree = AeonCreatureLimb(withLimb: parents.randomElement()!.limbThree)
        limbFour = AeonCreatureLimb(withLimb: parents.randomElement()!.limbFour)

        movementSpeed = parents.randomElement()!.movementSpeed
        sizeModififer = parents.randomElement()!.sizeModififer

        super.init()

        setupLimbs()
        setupBodyPhysics()
    }

    fileprivate func setupLimbs() {
        // Place limbs on body
        addChild(limbOne)
        addChild(limbTwo)
        addChild(limbThree)
        addChild(limbFour)
        // Position limbs on body
        limbOne.position = CGPoint(x: 0, y: randomInteger(min: 7, max: 10))
        limbTwo.position = CGPoint(x: randomInteger(min: 7, max: 10), y: 0)
        limbThree.position = CGPoint(x: 0, y: -randomInteger(min: 7, max: 10))
        limbFour.position = CGPoint(x: -randomInteger(min: 7, max: 10), y: 0)
    }

    private func setupBodyPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: 13)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = true
        physicsBody?.categoryBitMask = CollisionTypes.creature.rawValue
        physicsBody?.collisionBitMask = CollisionTypes.creature.rawValue | CollisionTypes.food.rawValue
        physicsBody?.contactTestBitMask = CollisionTypes.creature.rawValue | CollisionTypes.food.rawValue
        physicsBody?.affectedByGravity = false
        physicsBody?.restitution = 1
        physicsBody?.mass = 1
        physicsBody?.linearDamping = 0.5
        physicsBody?.angularDamping = 0

        let underShadow = SKSpriteNode(imageNamed: "aeonBodyShadow")
        underShadow.setScale(1.2)
        underShadow.alpha = 0.2
        addChild(underShadow)

        name = "aeonCreature"

        birth()
        beginWiggling()
    }

    func think(nodes: [SKNode], delta _: TimeInterval, time: TimeInterval) {
        // Decide what to do...

        if lifeState {
            if lastThinkTime == 0 {
                lastThinkTime = time
            }

            if currentHealth <= 100 {
                if currentState != .movingToFood || currentFoodTarget == nil || (time - lastThinkTime) > 3 {
                    currentState = .locatingFood
                    lastThinkTime = time
                }
            } else if currentHealth > 250, lifeTime >= 30 {
                if currentState != .movingToLove {
                    currentState = .locatingLove
                }
            } else if currentState != .randomMovement {
                beginRandomMovement()
            }

            if currentState == .locatingFood {
                // Decide to eat ...
                // Remove love target...
                currentLoveTarget = nil
                // Find closest food node...
                var foodDistanceArray = [(distance: CGFloat, interesed: Int, node: AeonFoodNode)]()
                for case let child as AeonFoodNode in nodes {
                    // if (child.creaturesInterested < 3) {
                    let distanceComputed = distance(point: child.position)
                    foodDistanceArray.append((distanceComputed, child.creaturesInterested, child))
                    // }
                }
                foodDistanceArray.sort(by: { $0.distance < $1.distance })

                // Pick first entry...

                if foodDistanceArray.count > 0 {
                    if let foodTarget = self.currentFoodTarget {
                        foodTarget.creaturesInterested -= 1
                    }
                    currentFoodTarget = foodDistanceArray[0].node
                    foodDistanceArray[0].node.creaturesInterested = foodDistanceArray[0].node.creaturesInterested + 1
                    currentState = .movingToFood
                }
            }

            if currentState == .locatingLove {
                // Decide to eat ...
                // Find furthest creature node...
                var creatureDifferenceArray = [(speed: CGFloat, distance: CGFloat, node: AeonCreatureNode)]()
                for case let child as AeonCreatureNode in nodes where
                    child != self
                    && parentNames.contains(child.lastName) == false
                    && child.parentNames.contains(lastName) == false {
                    let distanceComputed = distance(point: child.position)
                    creatureDifferenceArray.append((child.movementSpeed, distanceComputed, child))
                }

                creatureDifferenceArray.sort(by: { $0.distance < $1.distance })

                if creatureDifferenceArray.count > 0 {
                    currentLoveTarget = creatureDifferenceArray[0].node
                    currentState = .movingToLove
                }
            }

            if self.currentState == .randomMovement {
                var nodeFound = 0
                // Check if self is not already at point...
                if let moveTarget = self.currentMoveTarget {
                    let nodes = scene!.nodes(at: moveTarget)
                    for node in nodes where node == self {
                        nodeFound = 1
                    }
                    if nodeFound == 0 {
                        let moveToPoint = moveTarget
                        move(toCGPoint: moveToPoint)
                    } else {
                        beginRandomMovement()
                    }
                }
            }

            if self.currentState == .movingToFood {
                var nodeFound = 0

                // Check if node still exists at point...
                if let foodTarget = self.currentFoodTarget {
                    let nodes = scene!.nodes(at: foodTarget.position)
                    for node in nodes where node.name == "aeonFood" {
                        nodeFound = 1
                    }
                    if nodeFound == 1 {
                        move(toCGPoint: foodTarget.position)
                    } else {
                        currentFoodTarget = nil
                        currentState = .nothing
                    }
                }
            }

            if self.currentState == .movingToLove {
                // self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 0))
                var nodeFound = 0
                // Check if node still exists at point...
                if let loveTarget = self.currentLoveTarget {
                    let nodes = scene!.nodes(at: loveTarget.position)
                    for node in nodes {
                        if node.name == "aeonCreature", node != self {
                            nodeFound = 1
                        }
                    }
                    if nodeFound == 1 {
                        let moveToPoint = loveTarget.position
                        move(toCGPoint: moveToPoint)
                    } else {
                        currentLoveTarget = nil
                        currentState = .nothing
                    }
                }
            }
        }
    }

    func move(toCGPoint: CGPoint) {
        if self.action(forKey: "Rotating") == nil {
            let angleMovement = angleBetweenPointOne(pointOne: self.position, andPointTwo: toCGPoint)
            var rotationDuration: CGFloat = 0

            if self.zRotation > angleMovement {
                rotationDuration = abs(self.zRotation - angleMovement) * 2.5
            } else if self.zRotation < angleMovement {
                rotationDuration = abs(angleMovement - self.zRotation) * 2.5
            }

            if rotationDuration > 6 { rotationDuration = 6 }

            let rotationAction = SKAction.rotate(
                toAngle: angleMovement,
                duration: TimeInterval(rotationDuration),
                shortestUnitArc: true
            )

            rotationAction.timingMode = .easeInEaseOut

            self.run(rotationAction, withKey: "Rotating")
        }

        let radianFactor: CGFloat = 0.0174532925
        let rotationInDegrees = self.zRotation / radianFactor
        let newRotationDegrees = rotationInDegrees + 90
        let newRotationRadians = newRotationDegrees * radianFactor

        let thrustVector: CGVector = CGVector(
            dx: cos(newRotationRadians) * self.movementSpeed,
            dy: sin(newRotationRadians) * self.movementSpeed
        )

        self.physicsBody?.applyForce(thrustVector)
    }

    func beginRandomMovement() {
        let positionX = CGFloat(GKRandomDistribution(lowestValue: 0, highestValue: Int(scene!.size.width)).nextInt())
        let positionY = CGFloat(GKRandomDistribution(lowestValue: 0, highestValue: Int(scene!.size.height)).nextInt())
        let moveToPoint = CGPoint(x: positionX, y: positionY)
        self.currentMoveTarget = moveToPoint
        self.currentState = .randomMovement
    }

    func randomFloat(min: CGFloat, max: CGFloat) -> CGFloat {
        return (CGFloat(arc4random()) / 0xFFFF_FFFF) * (max - min) + min
    }

    func angleBetweenPointOne(pointOne: CGPoint, andPointTwo pointTwo: CGPoint) -> CGFloat {
        let xdiff = (pointTwo.x - pointOne.x)
        let ydiff = (pointTwo.y - pointOne.y)
        let rad = atan2(ydiff, xdiff)
        return rad - 1.5707963268 // convert from atan's right-pointing zero to CG's up-pointing zero
    }

    func distance(point: CGPoint) -> CGFloat {
        return CGFloat(hypotf(Float(point.x - self.position.x), Float(point.y - self.position.y)))
    }

    func birth() {
        NSLog("👼 Birth: \(self.fullName)")

        self.setScale(0.1)
        let birthAction = SKAction.scale(to: self.sizeModififer, duration: 30)
        self.run(birthAction)
    }

    func die() {
        NSLog("☠️ Death: \(self.fullName)")

        self.removeAllActions()
        self.physicsBody!.contactTestBitMask = 0
        self.lifeState = false
        self.endWiggling()

        // Remove interested creature from food target
        if let foodTarget = self.currentFoodTarget {
            foodTarget.creaturesInterested -= 1
        }

        self.zPosition = 0
        self.currentState = .dead
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 20)
        let shrinkOut = SKAction.scale(to: 0, duration: 20)
        self.run(SKAction.group([fadeOut, shrinkOut]), completion: {
            // Decrement creature count in scene
            // And remove selectedCreature from scene if it is self
            if let mainScene = self.scene as? GameScene {
                mainScene.creatureCount -= 1
                if mainScene.selectedCreature == self {
                    mainScene.selectedCreature = nil
                }
            }
            self.removeFromParent()
        })
    }

    func fed() {
        if self.currentState == .movingToFood {
            self.currentHealth += 300
            self.currentFoodTarget = nil
            self.currentState = .nothing
        }
    }

    func beginWiggling() {
        for case let child as SKSpriteNode in self.children {
            var wiggleFactor = GKRandomSource.sharedRandom().nextUniform()
            while wiggleFactor > 0.2 {
                wiggleFactor = GKRandomSource.sharedRandom().nextUniform()
            }
            let wiggleAction = SKAction.rotate(
                byAngle: CGFloat(wiggleFactor),
                duration: TimeInterval(GKRandomSource.sharedRandom().nextUniform())
            )
            let wiggleActionBack = SKAction.rotate(
                byAngle: CGFloat(-wiggleFactor),
                duration: TimeInterval(GKRandomSource.sharedRandom().nextUniform())
            )

            let wiggleMoveFactor = GKRandomSource.sharedRandom().nextUniform()
            let wiggleMoveFactor2 = GKRandomSource.sharedRandom().nextUniform()

            let wiggleMovement = SKAction.moveBy(
                x: CGFloat(wiggleMoveFactor),
                y: CGFloat(wiggleMoveFactor2),
                duration: TimeInterval(GKRandomSource.sharedRandom().nextUniform())
            )
            let wiggleMovementBack = SKAction.moveBy(
                x: CGFloat(-wiggleMoveFactor),
                y: CGFloat(-wiggleMoveFactor2),
                duration: TimeInterval(GKRandomSource.sharedRandom().nextUniform())
            )

            let wiggleAround = SKAction.group([wiggleAction, wiggleMovement])
            let wiggleAroundBack = SKAction.group([wiggleActionBack, wiggleMovementBack])

            child.run(SKAction.repeatForever(SKAction.sequence([wiggleAround, wiggleAroundBack])), withKey: "Wiggling")
        }
    }

    func endWiggling() {
        for case let child as SKSpriteNode in self.children {
            child.removeAction(forKey: "Wiggling")
        }
        self.removeAction(forKey: "Wiggling")
    }

    func age(lastUpdate: TimeInterval) {
        if lastUpdate < 10, self.currentHealth > 0 {
            self.currentHealth -= Float(lastUpdate)
            self.lifeTime += Float(lastUpdate)
        }
    }

    func ageWithoutDeath(lastUpdate: TimeInterval) {
        if lastUpdate < 10, self.currentHealth > 0 {
            if self.currentHealth - Float(lastUpdate) < 10 {
                self.currentHealth = 10
            } else {
                self.currentHealth -= Float(lastUpdate)
            }
            self.lifeTime += Float(lastUpdate)
        }
    }

    func getRandomShape() -> String {
        let randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: 2)

        switch randomNumber {
        case 0:
            return "aeonTriangle"
        case 1:
            return "aeonCircle"
        case 2:
            return "aeonSquare"
        default:
            return "aeonTriangle"
        }
    }

    func lifeTimeFormattedAsString() -> String {
        let aeonDays: Double = round(Double(lifeTime / 60) * 10) / 10
        let aeonYears: Double = round(aeonDays / 60 * 10) / 10

        if aeonDays < 60 {
            return "\(aeonDays) Minutes Old"
        } else {
            return "\(aeonYears) Hours Old"
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
