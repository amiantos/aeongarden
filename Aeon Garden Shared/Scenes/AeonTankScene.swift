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

protocol AeonTankDelegate: class {
    func updatePopulation(_ population: Int)
    func updateFood(_ food: Int)
    func updateBirths(_ births: Int)
    func updateDeaths(_ deaths: Int)
    func updateSelectedCreatureDetails(_ creature: AeonCreatureNode?)
}

class AeonTankScene: SKScene {
    public var deathCount: Int = 0
    public var birthCount: Int = 0

    private var foodPelletMax: Int = 20
    private var creatureMinimum: Int = 20

    private var lastFoodTime: TimeInterval = 0
    private var lastCreatureTime: TimeInterval = 0
    private var lastBubbleTime: TimeInterval = 0

    private var creatureNodes: [AeonCreatureNode] = [] {
        didSet {
            tankDelegate?.updatePopulation(creatureNodes.count)
            tankDelegate?.updateBirths(birthCount)
            tankDelegate?.updateDeaths(deathCount)
        }
    }
    private var foodNodes: [AeonFoodNode] = []  {
        didSet {
            tankDelegate?.updateFood(foodNodes.count)
        }
    }
    private var bubbleNodes: [AeonBubbleNode] = []

    private var cameraNode: SKCameraNode = SKCameraNode()

    weak var tankDelegate: AeonTankDelegate?

    var selectedCreature: AeonCreatureNode? {
        didSet {
            if selectedCreature == nil {
                camera?.removeAllActions()
                let zoomInAction = SKAction.scale(to: 1, duration: 1)
                let cameraAction = SKAction.move(
                    to: CGPoint(x: size.width / 2, y: size.height / 2),
                    duration: 1
                )
                camera?.run(SKAction.group([zoomInAction, cameraAction]))
            }
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
        creature.displaySelectionRing(withColor: .aeonUIBackgroundDark)
        camera?.run(SKAction.scale(to: 0.4, duration: 1))
    }

    // MARK: - Scene

    override func sceneDidLoad() {
        setupFrame()
        setupCamera()
        setupBackgroundGradient()
        setupBackgroundAnimation()
        createInitialCreatures()
        createInitialBubbles()
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

    override func update(_ currentTime: TimeInterval) {
        followSelectedCreatureWithCamera()
        tankDelegate?.updateSelectedCreatureDetails(selectedCreature)

        if lastCreatureTime == 0 {
            lastFoodTime = currentTime
            lastCreatureTime = currentTime
            lastBubbleTime = currentTime
        }

        if (currentTime - lastFoodTime) >= 3,
            foodNodes.count < foodPelletMax {
            addFoodPelletToScene()
            lastFoodTime = currentTime
        }

        if (currentTime - lastBubbleTime) >= 1 {
            addBubbleToScene()
            lastBubbleTime = currentTime
        }

//        if (currentTime - lastCreatureTime) >= 5,
//            creatureNodes.count < creatureMinimum {
//            addNewCreatureToScene(withPrimaryHue: randomCGFloat(min: 0, max: 360))
//            lastCreatureTime = currentTime
//        }

        var arrays: [Updatable] = []
        arrays.append(contentsOf: creatureNodes)
        arrays.append(contentsOf: foodNodes)
        arrays.append(contentsOf: bubbleNodes)
        for child in arrays {
            child.update(currentTime)
        }
    }

    // MARK: - Per Frame Processes

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
            let nodes = self.nodes(at: touchPoint)
            for node in nodes where node is AeonCreatureNode {
                if node == selectedCreature {
                    resetCamera()
                } else {
                    selectCreature(node as! AeonCreatureNode)
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
    fileprivate func createInitialCreatures() {
        var totalCreatures: Int = 0
        var initialCreatureHue: CGFloat = 0
        let colorHueIncrement: CGFloat = CGFloat(360 / CGFloat(creatureMinimum))

        while totalCreatures < creatureMinimum {
            addNewCreatureToScene(withPrimaryHue: initialCreatureHue)
            addFoodPelletToScene()
            totalCreatures += 1
            initialCreatureHue += colorHueIncrement
        }
    }

    fileprivate func createInitialBubbles() {
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
        if let creatureA = contact.bodyA.node as? AeonCreatureNode,
            let creatureB = contact.bodyB.node as? AeonCreatureNode {
            if creatureA.currentTarget == creatureB, creatureB.currentTarget == creatureA {
                // Mutual Reproduction
                creatureA.mated()
                creatureB.mated()
                AeonSoundManager.shared.play(.creatureMate, onNode: creatureA)
                // Random chance to breed
                if randomInteger(min: 0, max: 0) == 0 {
                    birthCount += 1
                    let newCreature = AeonCreatureNode(withParents: [creatureA, creatureB])
                    newCreature.position = creatureA.position
                    addChild(newCreature)
                    newCreature.born()
                    AeonSoundManager.shared.play(.creatureBorn, onNode: newCreature)
                    selectCreature(newCreature)
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

        if contact.bodyA.categoryBitMask == CollisionTypes.food.rawValue,
            contact.bodyB.categoryBitMask == CollisionTypes.creature.rawValue {
            if let creature = contact.bodyB.node as? AeonCreatureNode,
                let food = contact.bodyA.node as? AeonFoodNode,
                creature.currentTarget == food {
                creature.fed()
                food.eaten(animateTo: creature.position)
            }
        } else if contact.bodyB.categoryBitMask == CollisionTypes.food.rawValue,
            contact.bodyA.categoryBitMask == CollisionTypes.creature.rawValue {
            if let creature = contact.bodyA.node as? AeonCreatureNode,
                let food = contact.bodyB.node as? AeonFoodNode,
                creature.currentTarget == food {
                creature.fed()
                food.eaten(animateTo: creature.position)
            }
        }

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

// MARK: - Scene UI Setup

extension AeonTankScene {
    fileprivate func setupFrame() {
        size.width = frame.size.width * 2
        size.height = frame.size.height * 2
        backgroundColor = .aeonTankBgColor

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

    fileprivate func setupBackgroundGradient() {
//        let topColor = CIColor(color: UIColor(red: 0.0078, green: 0.0235, blue: 0.0275, alpha: 1.0)) /* #020607 */
//        let bottomColor = CIColor(color: UIColor(red: 0.1529, green: 0.4275, blue: 0.5373, alpha: 1.0)) /* #276d89 */
//
//        let textureSize = CGSize(width: frame.width * 2, height: frame.height * 3)
//        let texture = SKTexture(
//            size: CGSize(width: frame.width * 2, height: frame.height * 3),
//            color1: topColor,
//            color2: bottomColor,
//            direction: GradientDirection.upward
//        )
//        texture.filteringMode = .linear
//        let sprite = SKSpriteNode(texture: texture)
//        sprite.position = CGPoint(x: frame.midX, y: frame.midY)
//        sprite.size = textureSize
//        sprite.zPosition = -3
//        addChild(sprite)
//
//        let moveUpAction = SKAction.moveBy(x: 0, y: frame.height, duration: 60)
//        let moveDownAction = SKAction.moveBy(x: 0, y: -frame.height, duration: 60)
//        let moveActionGroup = SKAction.sequence([moveUpAction, moveDownAction, moveDownAction, moveUpAction])
//        moveActionGroup.timingMode = .easeInEaseOut
//        sprite.run(SKAction.repeatForever(moveActionGroup))
    }

    fileprivate func setupBackgroundAnimation() {
//        if let backgroundSmoke = SKEmitterNode(fileNamed: "AeonSomething.sks") {
//            backgroundSmoke.position = CGPoint(x: size.width / 2, y: size.height / 2)
//            backgroundSmoke.zPosition = -2
//            backgroundSmoke.particlePositionRange = CGVector(dx: size.width, dy: size.height)
//            let alphaSequence = SKKeyframeSequence(
//                keyframeValues: [0, 0.2, 0.3, 0.2, 0.15, 0],
//                times: [0, 0.25, 0.5, 0.75, 0.9, 1]
//            )
//            backgroundSmoke.particleAlphaSequence = alphaSequence
//            // backgroundSmoke.advanceSimulationTime(5)
//            backgroundSmoke.name = "backgroundShadow"
//            addChild(backgroundSmoke)
//        }

        if let backgroundSmoke2 = SKEmitterNode(fileNamed: "AeonOceanSquareBubbles.sks") {
            backgroundSmoke2.position = CGPoint(x: size.width / 2, y: size.height / 2)
            backgroundSmoke2.zPosition = -1
            backgroundSmoke2.particlePositionRange = CGVector(dx: size.width, dy: size.height)
            backgroundSmoke2.advanceSimulationTime(5)
            backgroundSmoke2.name = "backgroundSparkle"
            addChild(backgroundSmoke2)
        }
    }

}
