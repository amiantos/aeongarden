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
    let uuid: UUID

    var selectionRing: SKSpriteNode = SKSpriteNode(texture: selectionTexture)

    // MARK: - Creature Details

    public let firstName: String
    public var lastName: String
    public var fullName: String

    // MARK: - Inheritable Traits

    public var limbOne: AeonLimbNode
    public var limbTwo: AeonLimbNode
    public var limbThree: AeonLimbNode
    public var limbFour: AeonLimbNode

    public var movementSpeed: CGFloat = 1
    public var turnSpeed: CGFloat = 650
    public var sizeModififer: CGFloat = 1
    public let primaryHue: CGFloat

    // MARK: - User Settings

    public var isFavorite: Bool = false

    // MARK: - Current Focus

    public private(set) weak var currentTarget: SKNode?

    // MARK: - Health

    public private(set) var currentHealth: CGFloat = randomCGFloat(min: 100, max: 200) {
        didSet {
            if currentHealth <= 0 {
                die()
            }
        }
    }

    public var lifeTime: CGFloat = 0

    // MARK: - Brain

    private var brain: AeonCreatureBrain?
    internal var lastUpdateTime: TimeInterval = 0

    // MARK: - Creation

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(with creatureStruct: Creature) {
        firstName = creatureStruct.firstName
        lastName = creatureStruct.lastName
        fullName = "\(firstName) \(lastName)"

        limbOne = AeonLimbNode(with: creatureStruct.limbs[0])
        limbTwo = AeonLimbNode(with: creatureStruct.limbs[1])
        limbThree = AeonLimbNode(with: creatureStruct.limbs[2])
        limbFour = AeonLimbNode(with: creatureStruct.limbs[3])

        let hues: [CGFloat] = [limbOne.hue, limbTwo.hue, limbThree.hue, limbFour.hue]
        primaryHue = getAverageHue(hues)

        brain = AeonCreatureBrain()
        movementSpeed = CGFloat(creatureStruct.movementSpeed)
        sizeModififer = CGFloat(creatureStruct.sizeModifier)
        turnSpeed = CGFloat(creatureStruct.turnSpeed)

        uuid = creatureStruct.uuid

        super.init()
        brain?.delegate = self

        addChild(limbOne)
        addChild(limbTwo)
        addChild(limbThree)
        addChild(limbFour)
        limbOne.position = CGPoint(
            x: CGFloat(creatureStruct.limbs[0].positionX),
            y: CGFloat(creatureStruct.limbs[0].positionY)
        )
        limbTwo.position = CGPoint(
            x: CGFloat(creatureStruct.limbs[1].positionX),
            y: CGFloat(creatureStruct.limbs[1].positionY)
        )
        limbThree.position = CGPoint(
            x: CGFloat(creatureStruct.limbs[2].positionX),
            y: CGFloat(creatureStruct.limbs[2].positionY)
        )
        limbFour.position = CGPoint(
            x: CGFloat(creatureStruct.limbs[3].positionX),
            y: CGFloat(creatureStruct.limbs[3].positionY)
        )
        setupBodyPhysics()

        setScale(CGFloat(creatureStruct.sizeModifier))

        brain?.startThinking()
        brain?.currentState = .living
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

        uuid = UUID()

        super.init()

        brain?.delegate = self
        movementSpeed = randomCGFloat(min: 7, max: 12)
        sizeModififer = randomCGFloat(min: 0.7, max: 1.4)
        turnSpeed = randomCGFloat(min: 550, max: 750)

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

        limbOne = AeonLimbNode(withLimb: parents.randomElement()!.limbOne)
        limbTwo = AeonLimbNode(withLimb: parents.randomElement()!.limbTwo)
        limbThree = AeonLimbNode(withLimb: parents.randomElement()!.limbThree)
        limbFour = AeonLimbNode(withLimb: parents.randomElement()!.limbFour)

        let hues: [CGFloat] = [limbOne.hue, limbTwo.hue, limbThree.hue, limbFour.hue]
        primaryHue = getAverageHue(hues)

        brain = AeonCreatureBrain()
        movementSpeed = parents.randomElement()!.movementSpeed * randomCGFloat(min: 0.95, max: 1.05)
        sizeModififer = parents.randomElement()!.sizeModififer * randomCGFloat(min: 0.95, max: 1.05)
        turnSpeed = parents.randomElement()!.turnSpeed * randomCGFloat(min: 0.95, max: 1.05)

        uuid = UUID()

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

        let underShadow = SKSpriteNode(texture: shadowTexture)
        underShadow.size = CGSize(width: 40, height: 40)
        underShadow.setScale(1.2)
        underShadow.alpha = 0.2
        addChild(underShadow)

        name = fullName
        zPosition = 2

        beginWiggling()
    }

    // MARK: - Sensory Data

    func getCurrentState() -> String {
        return brain?.currentState.rawValue ?? "Newborn"
    }

    func getNodes() -> [SKNode] {
        return scene?.children ?? []
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
                    adjustedMovementSpeed *= 0.80
                } else if distanceToTarget < 75 {
                    adjustedMovementSpeed *= 0.5
                } else if distanceToTarget < 30 {
                    adjustedMovementSpeed *= 0.02
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
            let angleDivisor: CGFloat = turnSpeed

            physicsBody?.applyTorque(angleDifference / angleDivisor)
        }
    }

    // MARK: - Animations

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

    fileprivate func bounceAnimation() {
        let currentSize = (xScale + yScale) / 2
        let scaleDown = SKAction.scale(to: currentSize * 0.9, duration: 0.2)
        let scaleBounce = SKAction.scale(to: currentSize * 1.05, duration: 0.3)
        let scaleBounceIn = SKAction.scale(to: currentSize * 0.95, duration: 0.2)
        let scaleBounceBack = SKAction.scale(to: currentSize, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleDown, scaleBounce, scaleBounceIn, scaleBounceBack])
        run(scaleSequence)
    }

    fileprivate func createBubbleTrail() {
        // Create bubble trail
        if let emitter = AeonFileGrabber.shared.getSKEmitterNode(named: "AeonCreatureBubbleTrail") {
            emitter.particleTexture = triangleTexture
            emitter.name = "AeonCreatureBubbleTrail.sks"
            emitter.isUserInteractionEnabled = false
            emitter.zPosition = 1
            emitter.targetNode = scene
            let scaleSequence = SKKeyframeSequence(
                keyframeValues: [0.1, 0.25, 0.50, 0.75, 1],
                times: [0, 0.50, 0.70, 0.90, 1]
            )
            let alphaSequence = SKKeyframeSequence(
                keyframeValues: [0.5, 0.6, 0.5, 0.3, 0.15, 0],
                times: [0, 0.25, 0.5, 0.75, 0.9, 1]
            )
            emitter.particleAlphaSequence = alphaSequence
            emitter.particleScaleSequence = scaleSequence
            addChild(emitter)
        }
    }

    // MARK: - Lifecycle

    func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let deltaTime = currentTime - lastUpdateTime
        let correctedDeltaTime = deltaTime > 1 ? 1 : deltaTime
        if correctedDeltaTime >= 1, currentHealth > 0 {
            currentHealth -= CGFloat(correctedDeltaTime)
            lifeTime += CGFloat(correctedDeltaTime)
            lastUpdateTime = currentTime
        }
        brain?.update(currentTime)
        if currentHealth > 0 {
            move()
        }
    }

    func scaleAnimation() {
        setScale(0.1)
        let birthAction = SKAction.scale(to: sizeModififer, duration: 30)
        run(birthAction)
    }

    func born() {
        brain?.printThought("Lo! Consciousness", emoji: "👼")

        createBubbleTrail()
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
                if mainScene.selectedCreature == self {
                    mainScene.selectedCreature = nil
                }
            }
            if let scene = self.parent as? AeonTankScene {
                scene.removeChild(self)
            }
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

        bounceAnimation()
    }

    func fed(restorationAmount: CGFloat) {
        currentHealth += restorationAmount
        printThought("Yum!", emoji: "🍽")
        AeonSoundManager.shared.play(.creatureEat, onNode: self)
        brain?.fed(restorationAmount: restorationAmount)

        bounceAnimation()
    }

    func lifeTimeFormattedAsString() -> String {
        let minutes: Double = round(Double(lifeTime / 60) * 10) / 10
        let hours: Double = round(minutes / 60 * 10) / 10

        if minutes < 60 {
            return "\(minutes) Minutes"
        } else {
            return "\(hours) Hours"
        }
    }
}

// MARK: - Brain Delegate

extension AeonCreatureNode: AeonCreatureBrainDelegate {
    func getCurrentHealth() -> CGFloat {
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
            child != self {
            mateArray.append(child)
        }
        return mateArray
    }

    func getEligiblePlayMates() -> [AeonBubbleNode] {
        var playMates: [AeonBubbleNode] = []
        let nodes = getNodes()
        for child in nodes where
            child is AeonBubbleNode {
            playMates.append(child as! AeonBubbleNode)
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
        let similarHue = min(
            abs(mate.primaryHue - primaryHue),
            360 - abs(mate.primaryHue - primaryHue)
        )
        let distance = self.getDistance(toNode: mate)
        return similarHue + (distance / 2)
    }

    func printThought(_ message: String, emoji: String?) {
        Log.info("\(emoji ?? "💭") \(fullName) (\(Int(currentHealth))): \(message)")
    }
}

extension AeonCreatureNode: Selectable {
    func setupSelectionRing() {
        if childNode(withName: "selectionRing") == nil {
            selectionRing.name = "selectionRing"
            addChild(selectionRing)
            selectionRing.position = CGPoint(x: 0, y: 2)
            selectionRing.zPosition = -3
        }
    }

    func displaySelectionRing(withColor color: SKColor) {
        setupSelectionRing()
        selectionRing.color = color
        selectionRing.colorBlendFactor = 1
        selectionRing.alpha = 1
    }

    func hideSelectionRing() {
        if let ring = childNode(withName: "selectionRing") {
            removeChildren(in: [ring])
        }
    }
}
