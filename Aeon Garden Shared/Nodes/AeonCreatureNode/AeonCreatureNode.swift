//
//  AeonCreatureNode.swift
//  Aeon Garden
//
//  Created by Bradley Root on 9/30/17.
//  Copyright © 2017 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SpriteKit

class AeonCreatureNode: SKNode, Updatable {
    // MARK: - Creature Name

    public let firstName: String
    public var lastName: String
    public var fullName: String

    public var parentNames: [String] = []

    // MARK: - Inheritable Traits

    private var limbOne: AeonLimbNode
    private var limbTwo: AeonLimbNode
    private var limbThree: AeonLimbNode
    private var limbFour: AeonLimbNode

    public var movementSpeed: CGFloat = 1
    public var sizeModififer: CGFloat = 1
    public let primaryHue: CGFloat

    // MARK: - Current Focus

    weak public private(set) var currentTarget: SKNode?

    // MARK: - Health

    public private(set) var currentHealth: Float = Float(randomInteger(min: 50, max: 100)) {
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
        limbOne = AeonLimbNode(withPrimaryHue: primaryHue) // the "head"
        limbTwo = AeonLimbNode(withPrimaryHue: primaryHue)
        limbThree = AeonLimbNode(withPrimaryHue: primaryHue)
        limbFour = AeonLimbNode(withPrimaryHue: primaryHue)
        brain = AeonCreatureBrain()

        super.init()

        brain?.delegate = self
        movementSpeed = randomCGFloat(min: 7, max: 12)
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

        parentNames.append(parents[0].lastName)
        parentNames.append(parents[1].lastName)

        limbOne = AeonLimbNode(withLimb: parents.randomElement()!.limbOne)
        limbTwo = AeonLimbNode(withLimb: parents.randomElement()!.limbTwo)
        limbThree = AeonLimbNode(withLimb: parents.randomElement()!.limbThree)
        limbFour = AeonLimbNode(withLimb: parents.randomElement()!.limbFour)

        let hues: [CGFloat] = [limbOne.hue, limbTwo.hue, limbThree.hue, limbFour.hue]
        primaryHue = getAverageHue(hues)

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
        limbOne.position = CGPoint(x: 0, y: randomInteger(min: 8, max: 12))
        limbTwo.position = CGPoint(x: randomInteger(min: 7, max: 10), y: 0)
        limbThree.position = CGPoint(x: 0, y: -randomInteger(min: 7, max: 10))
        limbFour.position = CGPoint(x: -randomInteger(min: 7, max: 10), y: 0)
    }

    private func setupBodyPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: 16)
        physicsBody?.categoryBitMask = CollisionTypes.creature.rawValue
        physicsBody?.collisionBitMask = CollisionTypes.creature.rawValue | CollisionTypes.food.rawValue
        physicsBody?.contactTestBitMask = CollisionTypes.creature.rawValue | CollisionTypes.food.rawValue
        physicsBody?.affectedByGravity = false
        physicsBody?.restitution = 0.8
        physicsBody?.friction = 0.1
        physicsBody?.mass = 1
        physicsBody?.linearDamping = 0.5
        physicsBody?.angularDamping = 1

        let underShadow = SKSpriteNode(imageNamed: "aeonBodyShadow")
        underShadow.size = CGSize(width: 40, height: 40)
        underShadow.setScale(1.2)
        underShadow.alpha = 0.2
        addChild(underShadow)

        name = fullName
        zPosition = 2

        beginWiggling()
    }

    func beginWiggling() {
        for case let child as AeonLimbNode in children {
            child.beginWiggling()
        }
    }

    func endWiggling() {
        for case let child as AeonLimbNode in children {
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

    func angleBetween(pointOne: CGPoint, andPointTwo pointTwo: CGPoint) -> CGFloat {
        let xdiff = (pointTwo.x - pointOne.x)
        let ydiff = (pointTwo.y - pointOne.y)
        let rad = atan2(ydiff, xdiff)
        return rad - (CGFloat.pi / 2) // convert from atan's right-pointing zero to CG's up-pointing zero
    }

    // MARK: - Locomotion

    func move() {
        if let toCGPoint = currentTarget?.position {
            // Thrust
            let radianFactor: CGFloat = CGFloat.pi / 180
            let rotationInDegrees = zRotation / radianFactor
            let newRotationDegrees = rotationInDegrees + 90
            let newRotationRadians = newRotationDegrees * radianFactor

            var adjustedMovementSpeed = movementSpeed
            let distanceToTarget = distance(point: toCGPoint)

            if currentTarget is AeonCreatureNode || currentTarget is AeonFoodNode {
                if distanceToTarget < 150 {
                    adjustedMovementSpeed *= 0.75
                } else if distanceToTarget < 75 {
                    adjustedMovementSpeed *= 0.4
                } else if distanceToTarget < 30 {
                    adjustedMovementSpeed *= 0.05
                }
            }

            let thrustVector: CGVector = CGVector(
                dx: cos(newRotationRadians) * adjustedMovementSpeed,
                dy: sin(newRotationRadians) * adjustedMovementSpeed
            )

            physicsBody?.applyForce(thrustVector)

            // Rotation
            var goalAngle = angleBetween(pointOne: position, andPointTwo: toCGPoint)
            var creatureAngle = atan2(physicsBody!.velocity.dy, physicsBody!.velocity.dx) - (CGFloat.pi / 2)

            creatureAngle = convertRadiansToPi(creatureAngle)
            goalAngle = convertRadiansToPi(goalAngle)

            let angleDifference = convertRadiansToPi(goalAngle - creatureAngle)
            let angleDivisor: CGFloat = 600

            physicsBody?.applyTorque(angleDifference / angleDivisor)
        }
    }

    fileprivate func scaleAnimation() {
        let currentSize = (xScale + yScale) / 2
        let scaleUp = SKAction.scale(to: currentSize * 1.1, duration: 0.3)
        let scaleDown = SKAction.scale(to: currentSize * 0.9, duration: 0.3)
        let scaleBounce = SKAction.scale(to: currentSize * 1.05, duration: 0.3)
        let scaleBounceIn = SKAction.scale(to: currentSize * 0.95, duration: 0.2)
        let scaleBounceBack = SKAction.scale(to: currentSize, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown, scaleBounce, scaleBounceIn, scaleBounceBack])
        run(scaleSequence)
    }

    // MARK: - Lifecycle

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

    func born() {
        setScale(0.1)
        let birthAction = SKAction.scale(to: sizeModififer, duration: 30)
        run(birthAction)

//        if let emitter = SKEmitterNode(fileNamed: "AeonSmokeParticle.sks") {
//            emitter.name = "AeonSmokeParticle.sks"
//            emitter.zPosition = 1
//            emitter.targetNode = scene
//            let scaleSequence = SKKeyframeSequence(
//                keyframeValues: [0.1, 0.25, 0.50, 0.75, 1],
//                times: [0, 0.50, 0.70, 0.90, 1]
//            )
//            let alphaSequence = SKKeyframeSequence(
//                keyframeValues: [0.5, 0.6, 0.7, 0.5, 0],
//                times: [0, 0.25, 0.5, 0.75, 1]
//            )
//            emitter.particleAlphaSequence = alphaSequence
//            emitter.particleScaleSequence = scaleSequence
//            addChild(emitter)
//        }
    }

    func die() {
        brain?.die()
        currentTarget = nil
        removeAllActions()
        physicsBody!.contactTestBitMask = 0
        endWiggling()

        zPosition = 0
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 10)
        let shrinkOut = SKAction.scale(to: 0, duration: 10)
        run(SKAction.group([fadeOut, shrinkOut]), completion: {
            if let mainScene = self.scene as? AeonTankScene {
                mainScene.deathCount += 1
                mainScene.creatureCount -= 1
                if mainScene.selectedCreature == self {
                    mainScene.selectedCreature = nil
                }
            }
            self.removeFromParent()
        })
    }

    func wounded() {
        currentTarget = nil
        currentHealth /= 2
        printThought("Ouch!", emoji: "🤕")
    }

    func mated() {
        currentTarget = nil
        currentHealth /= 2
        printThought("That was nice!", emoji: "🥰")
        brain?.mated()

        scaleAnimation()
    }

    func fed() {
        currentHealth += Float(randomCGFloat(min: 80, max: 160))
        printThought("Yum!", emoji: "🍽")
        brain?.fed()

        scaleAnimation()
    }

    func lifeTimeFormattedAsString() -> String {
        let minutes: Double = round(Double(lifeTime / 60) * 10) / 10
        let hours: Double = round(minutes / 60 * 10) / 10

        if minutes < 60 {
            return "\(minutes) Minutes Old"
        } else {
            return "\(hours) Hours Old"
        }
    }
}

// MARK: - Brain Delegate

extension AeonCreatureNode: AeonCreatureBrainDelegate {
    func getCurrentHealth() -> Float {
        return currentHealth
    }

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
            child is AeonBubbleNode {
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

    /// Rate mate based on similarity of hue
    func rateMate(_ mate: AeonCreatureNode) -> CGFloat {
        return min(
            abs(mate.primaryHue - primaryHue),
            360 - abs(mate.primaryHue - primaryHue)
        )
    }

    func printThought(_ message: String, emoji: String?) {
        NSLog("\(emoji ?? "💭") \(fullName) (\(Int(currentHealth))): \(message)")
    }
}
