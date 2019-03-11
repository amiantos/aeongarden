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
    var currentFeeling: Feeling = .bored

    // MARK: - Health

    public var currentHealth: Float = Float(randomInteger(min: 125, max: 300))

    public var lifeTime: Float = 0

    // MARK: - Brain

    var brain: AeonCreatureBrain?

    var lastThinkTime: TimeInterval = 0

    func think(deltaTime: TimeInterval, currentTime: TimeInterval) {
        if (currentTime - lastThinkTime) > 1 {
            if currentHealth <= 0 {
                die()
                currentFeeling = .dying
            } else if currentHealth >= 600 {
                currentFeeling = .horny
            } else if currentHealth <= 300 {
                currentFeeling = .hungry
            }
//            } else if currentHealth <= 400, currentFeeling == .horny {
//                currentFeeling = .bored
//            }
            brain?.think(deltaTime: deltaTime)
            lastThinkTime = currentTime
        }
        move()
    }

    // MARK: - Creation

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

    init(withParents parents: [AeonCreatureNode]) {
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
        physicsBody?.angularDamping = 0

        let underShadow = SKSpriteNode(imageNamed: "aeonBodyShadow")
        underShadow.setScale(1.2)
        underShadow.alpha = 0.2
        addChild(underShadow)

        name = fullName

        born()
        beginWiggling()
    }

    func getNodes() -> [SKNode] {
        return scene!.children
    }

    func move() {
        if let toCGPoint = currentTarget?.position, currentFeeling != .dying {
            if action(forKey: "Rotating") == nil {
                let angleMovement = angleBetweenPointOne(pointOne: position, andPointTwo: toCGPoint)
                var rotationDuration: CGFloat = 0

                if zRotation > angleMovement {
                    rotationDuration = abs(zRotation - angleMovement) * 2.5
                } else if zRotation < angleMovement {
                    rotationDuration = abs(angleMovement - zRotation) * 2.5
                }

                if rotationDuration > 6 { rotationDuration = 6 }

                let rotationAction = SKAction.rotate(
                    toAngle: angleMovement,
                    duration: TimeInterval(rotationDuration),
                    shortestUnitArc: true
                )

                rotationAction.timingMode = .easeInEaseOut

                run(rotationAction, withKey: "Rotating")
            }

            let radianFactor: CGFloat = 0.0174532925
            let rotationInDegrees = zRotation / radianFactor
            let newRotationDegrees = rotationInDegrees + 90
            let newRotationRadians = newRotationDegrees * radianFactor

            let thrustVector: CGVector = CGVector(
                dx: cos(newRotationRadians) * movementSpeed,
                dy: sin(newRotationRadians) * movementSpeed
            )

            physicsBody?.applyForce(thrustVector)
        }
    }

    func angleBetweenPointOne(pointOne: CGPoint, andPointTwo pointTwo: CGPoint) -> CGFloat {
        let xdiff = (pointTwo.x - pointOne.x)
        let ydiff = (pointTwo.y - pointOne.y)
        let rad = atan2(ydiff, xdiff)
        return rad - 1.5707963268 // convert from atan's right-pointing zero to CG's up-pointing zero
    }

    func distance(point: CGPoint) -> CGFloat {
        return CGFloat(hypotf(Float(point.x - position.x), Float(point.y - position.y)))
    }

    // MARK: - Lifecycle

    func born() {
        setScale(0.1)
        let birthAction = SKAction.scale(to: sizeModififer, duration: 30)
        run(birthAction)
    }

    func die() {
        if currentFeeling != .dying {
            removeAllActions()
            physicsBody!.contactTestBitMask = 0
            endWiggling()

            zPosition = 0
            let fadeOut = SKAction.fadeAlpha(to: 0, duration: 10)
            let shrinkOut = SKAction.scale(to: 0, duration: 10)
            run(SKAction.group([fadeOut, shrinkOut]), completion: {
                if let mainScene = self.scene as? GameScene {
                    mainScene.deathCount += 1
                    if mainScene.selectedCreature == self {
                        mainScene.selectedCreature = nil
                    }
                }
                self.removeFromParent()
            })
        }
    }

    func mated() {
        currentHealth /= 2
        brain?.currentLoveTarget = nil
        printThought("That was nice!", emoji: "🥰")
    }

    func fed() {
        printThought("Yum!", emoji: "🍽")
        currentHealth += Float(randomCGFloat(min: 100, max: 200))
    }

    func beginWiggling() {
        for case let child as SKSpriteNode in children {
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
        for case let child as SKSpriteNode in children {
            child.removeAction(forKey: "Wiggling")
        }
        self.removeAction(forKey: "Wiggling")
    }

    func age(lastUpdate: TimeInterval) {
        if lastUpdate < 10, currentHealth > 0 {
            currentHealth -= Float(lastUpdate)
            lifeTime += Float(lastUpdate)
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

// MARK: - Brain Delegate

extension AeonCreatureNode: AeonCreatureBrainDelegate {
    func getFoodNodes() -> [AeonFoodNode] {
        var foodArray: [AeonFoodNode] = []
        let nodes = getNodes()
        for case let child as AeonFoodNode in nodes {
            foodArray.append(child)
        }
        return foodArray
    }

    func getEligibleMates() -> [AeonCreatureNode] {
        var mateArray: [AeonCreatureNode] = []
        let nodes = getNodes()
        for case let child as AeonCreatureNode in nodes where
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
            && (child is AeonFoodNode || child is AeonCreatureNode) {
            playMates.append(child)
        }
        return playMates
    }

    func setCurrentTarget(node: SKNode?) {
        currentTarget = node
    }

    func getCurrentFeeling() -> Feeling {
        return currentFeeling
    }

    func getDistance(toNode node: SKNode) -> CGFloat {
        return distance(point: node.position)
    }

    func rate(mate: AeonCreatureNode) -> CGFloat {
        return abs(mate.primaryHue - self.primaryHue)
    }

    func printThought(_ message: String, emoji: String?) {
        NSLog("\(emoji ?? "💭") \(fullName) (\(Int(currentHealth))): \(message)")
    }
}
