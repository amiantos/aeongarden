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
}

class AeonTankScene: SKScene {
    public var foodPelletCount: Int = 0
    public var creatureCount: Int = 0
    public var deathCount: Int = 0
    public var birthCount: Int = 0

    private var foodPelletMax: Int = 20
    private var creatureMinimum: Int = 10

    private var lastFoodTime: TimeInterval = 0
    private var lastCreatureTime: TimeInterval = 0
    private var lastUIUpdateTime: TimeInterval = 0
    private var totalTankTime: TimeInterval = 0
    private var lastBallTime: TimeInterval = 0

    private let creatureStatsNode = SKSpriteNode(imageNamed: "aeonStatsLine")
    private var nameLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
    private var lifeTimeLabel = SKLabelNode(fontNamed: "Helvetica-Light")
    private var healthLabel = SKLabelNode(fontNamed: "Helvetica-Light")
    private var currentStatusLabel = SKLabelNode(fontNamed: "Helvetica-Light")

    private var cameraNode: SKCameraNode = SKCameraNode()

    weak var tankDelegate: AeonTankDelegate?

    var selectedCreature: AeonCreatureNode? {
        didSet {
            if oldValue != selectedCreature {
                self.creatureStatsNode.removeAllActions()
                self.creatureStatsNode.alpha = 0
            }
            if selectedCreature == nil {
                self.creatureStatsNode.removeAllActions()
                self.creatureStatsNode.alpha = 0
                let zoomInAction = SKAction.scale(to: 1, duration: 1)
                let cameraAction = SKAction.move(
                    to: CGPoint(
                        x: self.size.width / 2,
                        y: self.size.height / 2
                    ),
                    duration: 1
                )
                camera?.run(SKAction.group([zoomInAction, cameraAction]))
            }
        }
    }

    // MARK: - Scene

    override func sceneDidLoad() {
        setupFrame()
        setupCamera()
        setupBackgroundGradient()
        setupBackgroundAnimation()
        setupCreatureStatsUI()
        createInitialCreatures()
        createInitialBalls()
    }

    override func didMove(to _: SKView) {
        physicsWorld.contactDelegate = self
    }

    override func update(_ currentTime: TimeInterval) {
        followSelectedCreatureWithCamera()

        if lastUIUpdateTime == 0 {
            lastFoodTime = currentTime
            lastCreatureTime = currentTime
            lastUIUpdateTime = currentTime
            lastBallTime = currentTime
        }

        if (currentTime - lastUIUpdateTime) >= 1 {
            tankDelegate?.updatePopulation(creatureCount)
            tankDelegate?.updateBirths(birthCount)
            tankDelegate?.updateDeaths(deathCount)

            var foodNodes = 0
            for case _ as AeonFoodNode in children {
                foodNodes += 1
            }
            foodPelletCount = foodNodes
            tankDelegate?.updateFood(foodPelletCount)

            lastUIUpdateTime = currentTime
        }

        if (currentTime - lastFoodTime) >= 2,
            foodPelletCount < foodPelletMax {
            addFoodPelletToScene()
            lastFoodTime = currentTime
        }

        if (currentTime - lastBallTime) >= 1 {
            addBallToScene()
            lastBallTime = currentTime
        }

        if (currentTime - lastCreatureTime) >= 5,
            creatureCount < creatureMinimum {
            addNewCreatureToScene(withPrimaryHue: randomCGFloat(min: 0, max: 360))
            lastCreatureTime = currentTime
        }

        for child in children {
            if let child = child as? Updatable {
                child.update(currentTime)
            }
        }
    }

    // MARK: - Per Frame Processes

    fileprivate func followSelectedCreatureWithCamera() {
        if let followCreature = self.selectedCreature {
            let cameraAction = SKAction.move(to: followCreature.position, duration: 0.25)
            camera?.run(cameraAction)
            nameLabel.text = followCreature.fullName
            lifeTimeLabel.text = followCreature.lifeTimeFormattedAsString()
            currentStatusLabel.text = followCreature.getCurrentState()
            healthLabel.text = "Health: \(Int(followCreature.currentHealth))"
        }
    }

    // MARK: - Touch Events

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        for touch in touches { touchDown(atPoint: touch.location(in: self)) }
        let touch = touches.first!
        let touchPoint = touch.location(in: self)
        let nodes = self.nodes(at: touchPoint)
        for node in nodes where node is AeonCreatureNode {
            if node == selectedCreature {
                self.selectedCreature = nil
                camera?.removeAllActions()
                let zoomInAction = SKAction.scale(to: 1, duration: 1)
                let cameraAction = SKAction.move(
                    to: CGPoint(x: self.size.width / 2, y: self.size.height / 2),
                    duration: 1
                )
                camera?.run(SKAction.group([zoomInAction, cameraAction]))
            } else {
                self.selectedCreature = node as? AeonCreatureNode
                let zoomInAction = SKAction.scale(to: 0.4, duration: 1)
                camera?.run(zoomInAction, completion: {
                    let fadeInAction = SKAction.fadeAlpha(to: 1, duration: 1)
                    self.creatureStatsNode.run(fadeInAction)
                })
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
}

// MARK: - Node Creation

extension AeonTankScene {
    fileprivate func createInitialCreatures() {
        var totalCreatures: Int = 0
        var initialCreatureHue: CGFloat = 0
        let colorHueIncrement: CGFloat = CGFloat(360 / CGFloat(20))

        while totalCreatures < 20 {
            addNewCreatureToScene(withPrimaryHue: initialCreatureHue)
            addFoodPelletToScene()
            totalCreatures += 1
            initialCreatureHue += colorHueIncrement
        }
    }

    fileprivate func createInitialBalls() {
        var ballCount: Int = 0
        let ballMinimum: Int = 10
        while ballCount < ballMinimum {
            addBallToScene()
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
        creatureCount += 1
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

    fileprivate func addBallToScene() {
        let aeonBall = AeonBallNode()
        aeonBall.position = CGPoint(
            x: randomCGFloat(min: size.width * 0.05, max: size.width * 0.95),
            y: randomCGFloat(min: size.height * 0.05, max: size.height * 0.95)
        )
        aeonBall.zRotation = randomCGFloat(min: 0, max: 10)
        addChild(aeonBall)
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
                // Random chance to breed
                if randomInteger(min: 0, max: 6) == 6 {
                    let newCreature = AeonCreatureNode(withParents: [creatureA, creatureB])
                    newCreature.position = creatureA.position
                    addChild(newCreature)
                    newCreature.born()
                    creatureCount += 1
                    birthCount += 1
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
            let ball = contact.bodyA.node as? AeonBallNode {
            ball.dieQuick()
        }

        if contact.bodyB.categoryBitMask == CollisionTypes.ball.rawValue,
            let ball = contact.bodyB.node as? AeonBallNode {
            ball.dieQuick()
        }
    }
}

// MARK: - Scene UI Setup

extension AeonTankScene {
    fileprivate func setupFrame() {
        size.width = frame.size.width * 2
        size.height = frame.size.height * 2

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = CollisionTypes.edge.rawValue
        physicsBody?.friction = 0
    }

    fileprivate func setupCamera() {
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
        camera = cameraNode
    }

    fileprivate func setupBackgroundGradient() {
        let topColor = CIColor(color: UIColor(red: 0.0078, green: 0.0235, blue: 0.0275, alpha: 1.0)) /* #020607 */
        let bottomColor = CIColor(color: UIColor(red: 0.1529, green: 0.4275, blue: 0.5373, alpha: 1.0)) /* #276d89 */

        let textureSize = CGSize(width: frame.width * 1.5, height: frame.height * 2)
        let texture = SKTexture(
            size: CGSize(width: 200, height: 200),
            color1: topColor,
            color2: bottomColor,
            direction: GradientDirection.upward
        )
        texture.filteringMode = .nearest
        let sprite = SKSpriteNode(texture: texture)
        sprite.position = CGPoint(x: frame.midX, y: frame.midY)
        sprite.size = textureSize
        sprite.zPosition = -3
        addChild(sprite)

        let moveUpAction = SKAction.moveBy(x: 0, y: 400, duration: 30)
        let moveDownAction = SKAction.moveBy(x: 0, y: -400, duration: 30)
        let moveActionGroup = SKAction.sequence([moveUpAction, moveDownAction, moveDownAction, moveUpAction])
        moveActionGroup.timingMode = .easeInEaseOut
        sprite.run(SKAction.repeatForever(moveActionGroup))
    }

    fileprivate func setupBackgroundAnimation() {
        if let backgroundSmoke2 = SKEmitterNode(fileNamed: "AeonOceanSparkle.sks") {
            backgroundSmoke2.position = CGPoint(x: size.width / 2, y: size.height / 2)
            backgroundSmoke2.zPosition = -1
            backgroundSmoke2.particlePositionRange = CGVector(dx: size.width, dy: size.height)
            backgroundSmoke2.advanceSimulationTime(5)
            backgroundSmoke2.name = "backgroundSparkle"
            addChild(backgroundSmoke2)
        }
    }

    fileprivate func setupCreatureStatsUI() {
        cameraNode.addChild(creatureStatsNode)
        creatureStatsNode.alpha = 0
        creatureStatsNode.size.width /= 1.2
        creatureStatsNode.position.x = creatureStatsNode.size.width / 2.2

        creatureStatsNode.addChild(nameLabel)
        nameLabel.position.x = 0
        nameLabel.position.y = 15
        nameLabel.alpha = 0.5
        nameLabel.horizontalAlignmentMode = .center
        nameLabel.verticalAlignmentMode = .bottom

        creatureStatsNode.addChild(lifeTimeLabel)
        lifeTimeLabel.position.x = 0
        lifeTimeLabel.position.y = -16
        lifeTimeLabel.fontSize = 25
        lifeTimeLabel.alpha = 0.3
        lifeTimeLabel.horizontalAlignmentMode = .center
        lifeTimeLabel.verticalAlignmentMode = .top

        creatureStatsNode.addChild(currentStatusLabel)
        currentStatusLabel.position.x = 0
        currentStatusLabel.position.y = -50
        currentStatusLabel.fontSize = 25
        currentStatusLabel.alpha = 0.3
        currentStatusLabel.horizontalAlignmentMode = .center
        currentStatusLabel.verticalAlignmentMode = .top

        creatureStatsNode.addChild(healthLabel)
        healthLabel.position.x = 0
        healthLabel.position.y = -86
        healthLabel.fontSize = 25
        healthLabel.alpha = 0.3
        healthLabel.horizontalAlignmentMode = .center
        healthLabel.verticalAlignmentMode = .top
    }
}
