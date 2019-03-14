//
//  AeonCreature.swift
//  Aeon Garden
//
//  Created by Bradley Root on 9/30/17.
//  Copyright © 2017 Brad Root. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit
import UIKit

class AeonCreature: SKNode, Updatable {
    // MARK: - Creature Name

    public let firstName: String
    public var lastName: String
    public var fullName: String

    public var parentNames: [String] = []

    // MARK: - Inheritable Traits

    private var limbOne: AeonCreatureLimb
    private var limbTwo: AeonCreatureLimb
    private var limbThree: AeonCreatureLimb
    private var limbFour: AeonCreatureLimb

    public var movementSpeed: CGFloat = 1
    public var sizeModififer: CGFloat = 1
    public let primaryHue: CGFloat

    // MARK: - Current Focus

    var currentTarget: SKNode?

    // MARK: - Health

    public var currentHealth: Float = Float(randomInteger(min: 125, max: 300)) {
        didSet {
            if currentHealth <= 0 {
                die()
            }
        }
    }
    public var lifeTime: Float = 0

    // MARK: - Brain

    private var brain: AeonCreatureBrain?
    internal var lastUpdateTime: TimeInterval = 0

    func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let deltaTime = currentTime - lastUpdateTime
        if deltaTime >= 1, currentHealth > 0 {
            currentHealth -= Float(deltaTime)
            lifeTime += Float(deltaTime)
            lastUpdateTime = currentTime
        }
        brain?.update(currentTime)
        if currentHealth > 0 {
            move()
        }
    }

    // MARK: - Creation

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(withPrimaryHue primaryHue: CGFloat) {
        firstName = AeonNameGenerator.shared.returnFirstName()
        lastName = AeonNameGenerator.shared.returnLastName()
        fullName = "\(firstName) \(lastName)"
        self.primaryHue = primaryHue

        // Create limbs
        limbOne = AeonCreatureLimb(withPrimaryHue: primaryHue) // the "head"
        limbTwo = AeonCreatureLimb(withPrimaryHue: primaryHue)
        limbThree = AeonCreatureLimb(withPrimaryHue: primaryHue)
        limbFour = AeonCreatureLimb(withPrimaryHue: primaryHue)
        brain = AeonCreatureBrain()

        super.init()

        brain?.delegate = self
        movementSpeed = randomCGFloat(min: 5, max: 10)
        sizeModififer = randomCGFloat(min: 0.7, max: 1.4)

        setupLimbs()
        setupBodyPhysics()

        brain?.startThinking()
    }

    init(withParents parents: [AeonCreature]) {
        if parents.count < 2 {
            fatalError("Virgin births are not allowed.")
        }

        firstName = AeonNameGenerator.shared.returnFirstName()
        lastName = parents.randomElement()!.lastName
        fullName = "\(firstName) \(lastName)"
        primaryHue = (parents[0].primaryHue + parents[1].primaryHue) / 2

        parentNames.append(parents[0].lastName)
        parentNames.append(parents[1].lastName)

        limbOne = AeonCreatureLimb(withLimb: parents.randomElement()!.limbOne)
        limbTwo = AeonCreatureLimb(withLimb: parents.randomElement()!.limbTwo)
        limbThree = AeonCreatureLimb(withLimb: parents.randomElement()!.limbThree)
        limbFour = AeonCreatureLimb(withLimb: parents.randomElement()!.limbFour)
        brain = AeonCreatureBrain()

        movementSpeed = parents.randomElement()!.movementSpeed * randomCGFloat(min: 0.95, max: 1.05)
        sizeModififer = parents.randomElement()!.sizeModififer * randomCGFloat(min: 0.95, max: 1.05)

        super.init()

        brain?.delegate = self

        setupLimbs()
        setupBodyPhysics()

        brain?.startThinking()
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
        physicsBody?.angularDamping = 1

        let underShadow = SKSpriteNode(imageNamed: "aeonBodyShadow")
        underShadow.setScale(1.2)
        underShadow.alpha = 0.2
        addChild(underShadow)

        name = fullName
        zPosition = 2

        born()
        beginWiggling()
    }

    func beginWiggling() {
        for case let child as AeonCreatureLimb in children {
            child.beginWiggling()
        }
    }

    func endWiggling() {
        for case let child as AeonCreatureLimb in children {
            child.endWiggling()
        }
    }

    // MARK: - Sensory Data

    func getCurrentState() -> String {
        return brain?.currentState.rawValue ?? "Newborn"
    }

    func getNodes() -> [SKNode] {
        return scene!.children
    }

    func distance(point: CGPoint) -> CGFloat {
        return CGFloat(hypotf(Float(point.x - position.x), Float(point.y - position.y)))
    }

    // MARK: - Locomotion

    func move() {
        if let toCGPoint = currentTarget?.position {

//            if action(forKey: "Rotating") == nil {
//                let angleMovement = angleBetween(pointOne: position, andPointTwo: toCGPoint)
//                var rotationDuration: CGFloat = 0
//
//                if zRotation > angleMovement {
//                    rotationDuration = abs(zRotation - angleMovement) * 2.5
//                } else if zRotation < angleMovement {
//                    rotationDuration = abs(angleMovement - zRotation) * 2.5
//                }
//
//                if rotationDuration > 6 { rotationDuration = 6 }
//
//                let rotationAction = SKAction.rotate(
//                    toAngle: angleMovement,
//                    duration: TimeInterval(rotationDuration),
//                    shortestUnitArc: true
//                )
//
//                rotationAction.timingMode = .easeInEaseOut
//
//                run(rotationAction, withKey: "Rotating")
//            }

            var goalAngle = angleBetween(pointOne: position, andPointTwo: toCGPoint)
            var creatureAngle = atan2(physicsBody!.velocity.dy, physicsBody!.velocity.dx) - (CGFloat.pi / 2)
            var angleDifference: CGFloat = 0

            if creatureAngle > CGFloat.pi {
                creatureAngle -= 2 * .pi
            } else if creatureAngle < -CGFloat.pi {
                creatureAngle += 2 * .pi
            }

            if goalAngle > CGFloat.pi {
                goalAngle -= 2 * .pi
            } else if goalAngle < -CGFloat.pi {
                goalAngle += 2 * .pi
            }

            angleDifference = goalAngle - creatureAngle
            if angleDifference > CGFloat.pi {
                angleDifference -= 2 * CGFloat.pi
            } else if angleDifference < -CGFloat.pi {
                angleDifference += 2 * CGFloat.pi
            }

            //print("Goal: \(goalAngle) cAngle: \(creatureAngle) Difference: \(angleDifference)")

            physicsBody?.applyTorque(angleDifference / 750)

            let radianFactor: CGFloat = CGFloat.pi / 180
            let rotationInDegrees = zRotation / radianFactor
            let newRotationDegrees = rotationInDegrees + 90
            let newRotationRadians = newRotationDegrees * radianFactor

            var adjustedMovementSpeed = movementSpeed
            let distanceToTarget = distance(point: toCGPoint)
            if distanceToTarget < 40 {
                adjustedMovementSpeed /= 2
            }
            print("Movement Speed: \(adjustedMovementSpeed) - Distance: \(distanceToTarget)")

            let thrustVector: CGVector = CGVector(
                dx: cos(newRotationRadians) * adjustedMovementSpeed,
                dy: sin(newRotationRadians) * adjustedMovementSpeed
            )

            physicsBody?.applyForce(thrustVector)
        }
    }

    func angleBetween(pointOne: CGPoint, andPointTwo pointTwo: CGPoint) -> CGFloat {
        let xdiff = (pointTwo.x - pointOne.x)
        let ydiff = (pointTwo.y - pointOne.y)
        let rad = atan2(ydiff, xdiff)
        return rad - (CGFloat.pi / 2) // convert from atan's right-pointing zero to CG's up-pointing zero
    }

    // MARK: - Lifecycle

    func born() {
//        setScale(0.1)
//        let birthAction = SKAction.scale(to: sizeModififer, duration: 30)
//        run(birthAction)
    }

    func die() {
        brain?.die()
        removeAllActions()
        physicsBody!.contactTestBitMask = 0
        endWiggling()

        zPosition = 0
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 10)
        let shrinkOut = SKAction.scale(to: 0, duration: 10)
        run(SKAction.group([fadeOut, shrinkOut]), completion: {
            if let mainScene = self.scene as? AeonTank {
                mainScene.deathCount += 1
                mainScene.creatureCount -= 1
                if mainScene.selectedCreature == self {
                    mainScene.selectedCreature = nil
                }
            }
            self.removeFromParent()
        })
    }

    func mated() {
        currentHealth /= 2
        printThought("That was nice!", emoji: "🥰")
    }

    func fed() {
        printThought("Yum!", emoji: "🍽")
        currentHealth += Float(randomCGFloat(min: 100, max: 200))
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

}

// MARK: - Brain Delegate

extension AeonCreature: AeonCreatureBrainDelegate {
    func getCurrentHealth() -> Float {
        return currentHealth
    }

    func getFoodNodes() -> [AeonFood] {
        var foodArray: [AeonFood] = []
        let nodes = getNodes()
        for case let child as AeonFood in nodes {
            foodArray.append(child)
        }
        return foodArray
    }

    func getEligibleMates() -> [AeonCreature] {
        var mateArray: [AeonCreature] = []
        let nodes = getNodes()
        for case let child as AeonCreature in nodes where
            child != self
            && parentNames.contains(child.lastName) == false
            && child.parentNames.contains(lastName) == false {
            mateArray.append(child)
        }
        return mateArray
    }

    func getEligiblePlayMates() -> [SKNode] {
        var playMates: [SKNode] = []
        let nodes = getNodes()
        for child in nodes where
            child != self
            && (child is AeonFood || child is AeonCreature) {
            playMates.append(child)
        }
        return playMates
    }

    func setCurrentTarget(node: SKNode?) {
        currentTarget = node
    }

    func getDistance(toNode node: SKNode) -> CGFloat {
        return distance(point: node.position)
    }

    func rate(mate: AeonCreature) -> CGFloat {
        return abs(mate.primaryHue - self.primaryHue)
    }

    func printThought(_ message: String, emoji: String?) {
        NSLog("\(emoji ?? "💭") \(fullName) (\(Int(currentHealth))): \(message)")
    }
}
