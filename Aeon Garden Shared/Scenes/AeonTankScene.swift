//
//  AeonTankScene.swift
//  Aeon Garden
//
//  Created by Bradley Root on 9/30/17.
//  Copyright © 2017 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import GameplayKit
import SpriteKit

enum CollisionTypes: UInt32 {
    case creature = 1
    case food = 2
    case edge = 4
    case ball = 8
}

protocol AeonTankUIDelegate: AnyObject {
    func updatePopulation(_ population: Int)
    func updateFood(_ food: Int)
    func updateBirths(_ births: Int)
    func updateDeaths(_ deaths: Int)
    func updateClock(_ clock: String)
    func updateSelectedCreatureDetails(_ creature: AeonCreatureNode)
    func creatureDeselected()
    func creatureSelected(_ creature: AeonCreatureNode)
}

class AeonTankScene: SKScene {
    let uuid: UUID = UUID()

    public var tankSettings: TankSettings? {
        didSet {
            setupTankSettings()
        }
    }

    public var tankTime: TimeInterval = 0

    public var deathCount: Int = 0
    public var birthCount: Int = 0

    private var foodMaxAmount: Int = 30
    private var foodHealthRestorationBaseValue: CGFloat = 120
    private var foodSpawnRate: Int = 2

    private var creatureMinimumAmount: Int = 10
    private var creatureInitialAmount: Int = 20
    private var creatureSpawnRate: Int = 5
    private var creatureBirthSuccessRate: CGFloat = 0.17

    private var backgroundParticleBirthrate: Int = 40
    private var backgroundParticleLifetime: Int = 30

    private var lastFoodTime: TimeInterval = 0
    private var lastCreatureTime: TimeInterval = 0
    private var lastBubbleTime: TimeInterval = 0

    public var creatureNodes: [AeonCreatureNode] = [] {
        didSet {
            tankDelegate?.updatePopulation(creatureNodes.count)
            tankDelegate?.updateBirths(birthCount)
            tankDelegate?.updateDeaths(deathCount)
        }
    }

    public var foodNodes: [AeonFoodNode] = [] {
        didSet {
            tankDelegate?.updateFood(foodNodes.count)
        }
    }

    public var bubbleNodes: [AeonBubbleNode] = []

    private var cameraNode: SKCameraNode = SKCameraNode()

    weak var tankDelegate: AeonTankUIDelegate? {
        didSet {
            tankDelegate?.updatePopulation(creatureNodes.count)
        }
    }

    var selectedCreature: AeonCreatureNode? {
        didSet {
            zoomOutCameraIfNeeded()
        }
    }

    // MARK: - Scene

    override func sceneDidLoad() {
        setupFrame()
        setupCamera()
        setupBackgroundAnimation()
    }

    override func didMove(to _: SKView) {
        physicsWorld.contactDelegate = self
    }

    override func addChild(_ node: SKNode) {
        if let creature = node as? AeonCreatureNode {
            creatureNodes.append(creature)
        } else if let food = node as? AeonFoodNode {
            foodNodes.append(food)
        } else if let bubble = node as? AeonBubbleNode {
            bubbleNodes.append(bubble)
        }
        super.addChild(node)
    }

    func removeChild(_ node: SKNode) {
        if let creature = node as? AeonCreatureNode {
            creatureNodes.remove(object: creature)
        } else if let food = node as? AeonFoodNode {
            foodNodes.remove(object: food)
        } else if let bubble = node as? AeonBubbleNode {
            bubbleNodes.remove(object: bubble)
        }
        node.removeFromParent()
    }

    // MARK: - Main Loop

    override func update(_ currentTime: TimeInterval) {
        followSelectedCreatureWithCamera()

        if lastCreatureTime == 0 {
            lastFoodTime = currentTime
            lastCreatureTime = currentTime
            lastBubbleTime = currentTime
        }

        Log.debug("Food Spawner: Last Spawn \(currentTime - lastFoodTime) - Current Food: \(foodNodes.count) - Max Food: \(foodMaxAmount)")
        if (currentTime - lastFoodTime) >= 2,
            foodNodes.count < foodMaxAmount {
            addFoodPelletToScene()
            lastFoodTime = currentTime
        }

        if (currentTime - lastBubbleTime) >= 1 {
            addBubbleToScene()

            let deltaTime = currentTime - lastBubbleTime
            let correctedDelta = deltaTime > 1 ? 1 : deltaTime
            tankTime += correctedDelta

            // UI Updates (Kludge)
            tankDelegate?.updateClock(toTimestamp(timeInterval: tankTime))
            if let creature = selectedCreature {
                tankDelegate?.updateSelectedCreatureDetails(creature)
            }

            lastBubbleTime = currentTime
        }

        if (currentTime - lastCreatureTime) >= 5,
            creatureNodes.count < creatureMinimumAmount {
            addNewCreatureToScene(withPrimaryHue: randomCGFloat(min: 0, max: 360))
            lastCreatureTime = currentTime
        }

        creatureNodes.forEach { $0.update(currentTime) }
        foodNodes.forEach { $0.update(currentTime) }
        bubbleNodes.forEach { $0.update(currentTime) }
    }

    // MARK: - Camera Controls

    fileprivate func zoomOutCameraIfNeeded() {
        if let creature = selectedCreature {
            tankDelegate?.creatureSelected(creature)
        } else {
            tankDelegate?.creatureDeselected()
            camera?.removeAllActions()
            let zoomInAction = SKAction.scale(to: 1, duration: 1)
            let cameraAction = SKAction.move(
                to: CGPoint(x: size.width / 2, y: size.height / 2),
                duration: 1
            )
            camera?.run(SKAction.group([zoomInAction, cameraAction]))
        }
    }

    func resetCamera() {
        selectedCreature?.hideSelectionRing()
        selectedCreature = nil
        camera?.removeAllActions()
        let zoomInAction = SKAction.scale(to: 1, duration: 1)
        let cameraAction = SKAction.move(
            to: CGPoint(x: size.width / 2, y: size.height / 2),
            duration: 1
        )
        camera?.run(SKAction.group([zoomInAction, cameraAction]))
    }

    func selectCreature(_ creature: AeonCreatureNode) {
        if creature != selectedCreature {
            selectedCreature?.hideSelectionRing()
        }
        selectedCreature = creature
        print(Creature.from(creature))
        creature.displaySelectionRing(withColor: .aeonBrightYellow)
//        camera?.run(SKAction.scale(to: UISettings.styles.cameraZoomScale, duration: 1))
        camera?.run(SKAction.scale(to: 0.4, duration: 1))
    }

    func deselectCreature() {
        selectedCreature?.hideSelectionRing()
        selectedCreature = nil
    }

    fileprivate func followSelectedCreatureWithCamera() {
        if let followCreature = self.selectedCreature {
            let cameraAction = SKAction.move(to: followCreature.position, duration: 0.25)
            camera?.run(cameraAction)
        }
    }

    // MARK: - Touch Events

    #if os(iOS)
        override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
            for touch in touches { touchDown(atPoint: touch.location(in: self)) }
            let touch = touches.first!
            let touchPoint = touch.location(in: self)

            var creatureLocationArray = [(distance: CGFloat, node: AeonCreatureNode)]()
            creatureNodes.forEach {
                creatureLocationArray.append(($0.distance(point: touchPoint), $0))
            }
            creatureLocationArray.sort(by: { $0.distance < $1.distance })
            if !creatureLocationArray.isEmpty {
                let creature = creatureLocationArray[0].node
                let distance = creatureLocationArray[0].distance
                if distance >= 50, selectedCreature != nil {
                    resetCamera()
                } else if distance >= 50 {
                    return
                } else if creature == selectedCreature {
                    resetCamera()
                } else {
                    selectCreature(creature)
                }
            }
        }

        func touchDown(atPoint _: CGPoint) {}

        func touchMoved(toPoint _: CGPoint) {}

        func touchUp(atPoint _: CGPoint) {}

        override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
            for touch in touches { touchMoved(toPoint: touch.location(in: self)) }
        }

        override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
            for touch in touches { touchUp(atPoint: touch.location(in: self)) }
        }

        override func touchesCancelled(_ touches: Set<UITouch>, with _: UIEvent?) {
            for touch in touches { touchUp(atPoint: touch.location(in: self)) }
        }
    #endif
}

// MARK: - Node Creation

extension AeonTankScene {
    public func createInitialCreatures() {
        var totalCreatures: Int = 0
        var initialCreatureHue: CGFloat = 0
        let colorHueIncrement: CGFloat = CGFloat(360 / CGFloat(creatureInitialAmount))

        while totalCreatures < creatureInitialAmount {
            addNewCreatureToScene(withPrimaryHue: initialCreatureHue)
            addFoodPelletToScene()
            totalCreatures += 1
            initialCreatureHue += colorHueIncrement
        }
    }

    public func createInitialBubbles() {
        var ballCount: Int = 0
        let ballMinimum: Int = 10
        while ballCount < ballMinimum {
            addBubbleToScene()
            ballCount += 1
        }
    }

    fileprivate func addNewCreatureToScene(withPrimaryHue primaryHue: CGFloat) {
        let aeonCreature = AeonCreatureNode(withPrimaryHue: primaryHue)
        aeonCreature.position = CGPoint(
            x: randomCGFloat(min: size.width * 0.05, max: size.width * 0.95),
            y: randomCGFloat(min: size.height * 0.05, max: size.height * 0.95)
        )
        aeonCreature.zRotation = randomCGFloat(min: 0, max: 10)
        aeonCreature.zPosition = 12
        addChild(aeonCreature)
        aeonCreature.born()
    }

    fileprivate func addFoodPelletToScene() {
        let aeonFood = AeonFoodNode()
        aeonFood.position = CGPoint(
            x: randomCGFloat(min: size.width * 0.05, max: size.width * 0.95),
            y: randomCGFloat(min: size.height * 0.05, max: size.height * 0.95)
        )
        aeonFood.zRotation = randomCGFloat(min: 0, max: 10)
        addChild(aeonFood)
        aeonFood.born()
    }

    fileprivate func addBubbleToScene() {
        let aeonBubble = AeonBubbleNode()
        aeonBubble.position = CGPoint(
            x: randomCGFloat(min: size.width * 0.05, max: size.width * 0.95),
            y: randomCGFloat(min: size.height * 0.05, max: size.height * 0.95)
        )
        aeonBubble.zRotation = randomCGFloat(min: 0, max: 10)
        addChild(aeonBubble)
    }
}

// MARK: - Physics Interactions

extension AeonTankScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // MARK: - Mating

        if let creatureA = contact.bodyA.node as? AeonCreatureNode,
            let creatureB = contact.bodyB.node as? AeonCreatureNode {
            if creatureA.currentTarget == creatureB, creatureB.currentTarget == creatureA {
                // Mutual Reproduction
                creatureA.mated()
                creatureB.mated()
                AeonSoundManager.shared.play(.creatureMate, onNode: creatureA)
                // Random chance to breed
                if randomCGFloat(min: 0, max: 1) <= creatureBirthSuccessRate {
                    birthCount += 1
                    let newCreature = AeonCreatureNode(withParents: [creatureA, creatureB])
                    newCreature.position = creatureA.position
                    addChild(newCreature)
                    newCreature.born()
                    AeonSoundManager.shared.play(.creatureBorn, onNode: newCreature)
//                    selectCreature(newCreature)
                }
            } else {
                // If one creature is pursuing the other, get wrecked
                if creatureA.currentTarget == creatureB {
                    creatureA.wounded()
                } else if creatureB.currentTarget == creatureA {
                    creatureB.wounded()
                }
            }
        }

        // MARK: - Eating

        if contact.bodyA.categoryBitMask == CollisionTypes.food.rawValue,
            contact.bodyB.categoryBitMask == CollisionTypes.creature.rawValue {
            if let creature = contact.bodyB.node as? AeonCreatureNode,
                let food = contact.bodyA.node as? AeonFoodNode,
                creature.getCurrentState() == "Hungry" {
                creature.fed(restorationAmount: foodHealthRestorationBaseValue)
                food.eaten(animateTo: creature.position)
            }
        } else if contact.bodyB.categoryBitMask == CollisionTypes.food.rawValue,
            contact.bodyA.categoryBitMask == CollisionTypes.creature.rawValue {
            if let creature = contact.bodyA.node as? AeonCreatureNode,
                let food = contact.bodyB.node as? AeonFoodNode,
                creature.getCurrentState() == "Hungry" {
                creature.fed(restorationAmount: foodHealthRestorationBaseValue * randomCGFloat(min: 0.5, max: 1.5))
                food.eaten(animateTo: creature.position)
            }
        }

        // MARK: - Bubble Collisions

        if contact.bodyA.categoryBitMask == CollisionTypes.ball.rawValue,
            let ball = contact.bodyA.node as? AeonBubbleNode {
            ball.dieQuick()
        }

        if contact.bodyB.categoryBitMask == CollisionTypes.ball.rawValue,
            let ball = contact.bodyB.node as? AeonBubbleNode {
            ball.dieQuick()
        }
    }
}

// MARK: - Scene Setup

extension AeonTankScene {
    fileprivate func setupTankSettings() {
        guard let settings = tankSettings else {
            Log.error("Tank settings not found.")
            return
        }
        foodMaxAmount = settings.foodMaxAmount
        foodHealthRestorationBaseValue = CGFloat(settings.foodHealthRestorationBaseValue)
        foodSpawnRate = settings.foodSpawnRate

        creatureInitialAmount = settings.creatureInitialAmount
        creatureMinimumAmount = settings.creatureMinimumAmount
        creatureSpawnRate = settings.creatureSpawnRate
        creatureBirthSuccessRate = CGFloat(settings.creatureBirthSuccessRate)

        backgroundParticleBirthrate = settings.backgroundParticleBirthrate
        backgroundParticleLifetime = settings.backgroundParticleLifetime
    }

    fileprivate func setupFrame() {
        size.width = frame.size.width * 2
        size.height = frame.size.height * 2
        backgroundColor = .aeonDarkBlue

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = CollisionTypes.edge.rawValue
        physicsBody?.friction = 0
    }

    fileprivate func setupCamera() {
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
        camera = cameraNode

//        listener = cameraNode
//        audioEngine.mainMixerNode.outputVolume = 0.2
    }

    fileprivate func setupBackgroundAnimation() {
        guard let emitter = AeonFileGrabber.shared.getSKEmitterNode(named: "AeonOceanSquareBubbles") else { return }
        emitter.particleTexture = squareTexture
        emitter.position = CGPoint(x: size.width / 2, y: size.height / 2)
        emitter.zPosition = -1
        emitter.particlePositionRange = CGVector(dx: size.width, dy: size.height)
        emitter.advanceSimulationTime(5)
        emitter.name = "backgroundSparkle"
        addChild(emitter)
    }
}
