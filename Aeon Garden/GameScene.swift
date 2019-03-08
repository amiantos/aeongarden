//
//  GameScene.swift
//  Aeon Garden
//
//  Created by Bradley Root on 9/30/17.
//  Copyright © 2017 Brad Root. All rights reserved.
//

import GameplayKit
import SpriteKit

enum CollisionTypes: UInt32 {
    case creature = 1
    case food = 2
    case edge = 4
}

class GameScene: SKScene {
    var entities = [GKEntity]()
    var graphs = [String: GKGraph]()

    public var foodPelletCount: Int = 0
    public var creatureCount: Int = 0

    private var foodPelletMax: Int = 100
    private var creatureMax: Int = 20
    private var totalCreatures: Int = 0
    private var initialCreatureHue: CGFloat = 0
    private let colorHueIncrement: CGFloat = CGFloat(360 / 20)

    private var lastUpdateTime: TimeInterval = 0
    private var lastFoodTime: TimeInterval = 0
    private var lastThinkTime: TimeInterval = 0
    private var lastCreatureTime: TimeInterval = 0

    private var creatureCountLabel = SKLabelNode(fontNamed: "Helvetica-Light")
    private let creatureCountShape = SKShapeNode(rect: CGRect(x: 0, y: -100, width: 200, height: 60))

    private let creatureStatsNode = SKSpriteNode(imageNamed: "aeonStatsLine")
    private var nameLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
    private var lifeTimeLabel = SKLabelNode(fontNamed: "Helvetica-Light")
    private var healthLabel = SKLabelNode(fontNamed: "Helvetica-Light")
    private var currentStatusLabel = SKLabelNode(fontNamed: "Helvetica-Light")

    private var cameraNode: SKCameraNode = SKCameraNode()

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
                    to: CGPoint(x: self.size.width / 2, y: self.size.height / 2),
                    duration: 1
                )
                camera?.run(SKAction.group([zoomInAction, cameraAction]))
            }
        }
    }

    // MARK: - Scene Setup

    override func sceneDidLoad() {
        setupFrame()
        setupCamera()
        setupBackgroundAnimation()
        setupCreatureCountUI()
        setupCreatureStatsUI()
        createInitialCreatures()
    }

    override func didMove(to _: SKView) {
        physicsWorld.contactDelegate = self
    }

    override func update(_ currentTime: TimeInterval) {
        followSelectedCreatureWithCamera()

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            lastFoodTime = currentTime
            lastThinkTime = currentTime
            lastCreatureTime = currentTime
        }

        if (currentTime - lastFoodTime) > 2,
            foodPelletCount < foodPelletMax {
            addFoodPelletToScene()
            lastFoodTime = currentTime
        }

        if (currentTime - lastCreatureTime) > 600 {
            addNewCreatureToScene()
            lastCreatureTime = currentTime
        }

        creatureCountLabel.text = "Alive: \(creatureCount)"

        let deltaTime = currentTime - lastUpdateTime
        perFrameNodeActivity(deltaTime, currentTime)

        lastUpdateTime = currentTime
    }

    // MARK: - Node Creation

    fileprivate func createInitialCreatures() {
        var totalCreatures: Int = 0
        var initialCreatureHue: CGFloat = 0
        let colorHueIncrement: CGFloat = CGFloat(360 / creatureMax)

        while totalCreatures < creatureMax {
            addNewCreatureToScene()
            totalCreatures += 1
            initialCreatureHue += colorHueIncrement
        }
    }

    fileprivate func addNewCreatureToScene() {
        let aeonCreature = AeonCreatureNode()
        let foodPositionX = randomCGFloat(min: size.width * 0.10, max: size.width * 0.90)
        let foodPositionY = randomCGFloat(min: size.height * 0.10, max: size.height * 0.90)
        aeonCreature.position = CGPoint(x: foodPositionX, y: foodPositionY)
        aeonCreature.zRotation = randomCGFloat(min: 0, max: 10)
        aeonCreature.zPosition = 12
        addChild(aeonCreature)
        creatureCount += 1
    }

    fileprivate func addFoodPelletToScene() {
        let aeonFood = AeonFoodNode()
        let foodPositionX = CGFloat(
            GKRandomDistribution(
                lowestValue: Int(size.width * 0.01),
                highestValue: Int(size.width * 0.99)
            ).nextInt()
        )
        let foodPositionY = CGFloat(
            GKRandomDistribution(
                lowestValue: Int(size.height * 0.01),
                highestValue: Int(size.height * 0.99)
            ).nextInt()
        )
        aeonFood.position = CGPoint(x: foodPositionX, y: foodPositionY)
        aeonFood.zRotation = CGFloat(GKRandomDistribution(lowestValue: 0, highestValue: 10).nextInt())
        addChild(aeonFood)
        foodPelletCount += 1
    }

    // MARK: - Per Frame Processes

    fileprivate func perFrameNodeActivity(_ deltaTime: Double, _ currentTime: TimeInterval) {
        for child in children {
            if let child = child as? AeonCreatureNode {
                child.think(nodes: children, delta: deltaTime, time: currentTime)
                if child != selectedCreature {
                    child.age(lastUpdate: deltaTime)
                } else {
                    child.ageWithoutDeath(lastUpdate: deltaTime)
                }
            } else if let child = child as? AeonFoodNode {
                child.age(lastUpdate: deltaTime)
            }
        }
    }

    fileprivate func followSelectedCreatureWithCamera() {
        if let followCreature = self.selectedCreature {
            let cameraAction = SKAction.move(to: followCreature.position, duration: 0.25)
            camera?.run(cameraAction)
            nameLabel.text = followCreature.fullName
            lifeTimeLabel.text = followCreature.lifeTimeFormattedAsString()
            currentStatusLabel.text = followCreature.currentState.rawValue
            healthLabel.text = "Health: \(Int(followCreature.currentHealth))"
        }
    }

    // MARK: - Touch Events

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        for touch in touches { touchDown(atPoint: touch.location(in: self)) }
        let touch = touches.first!
        let touchPoint = touch.location(in: self)
        let nodes = self.nodes(at: touchPoint)
        for node in nodes where node.name == "aeonCreature" {
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

    // MARK: - Scene UI Setup

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

    fileprivate func setupBackgroundAnimation() {
//        if let backgroundSmoke = SKEmitterNode(fileNamed: "AeonSmokeParticle.sks") {
//            backgroundSmoke.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
//            backgroundSmoke.zPosition = -2
//            backgroundSmoke.particlePositionRange = CGVector(dx: self.size.width, dy: self.size.height)
//            backgroundSmoke.advanceSimulationTime(5)
//            self.addChild(backgroundSmoke)
//        }
        if let backgroundSmoke2 = SKEmitterNode(fileNamed: "AeonOceanSparkle.sks") {
            backgroundSmoke2.position = CGPoint(x: size.width / 2, y: size.height / 2)
            backgroundSmoke2.zPosition = -1
            backgroundSmoke2.particlePositionRange = CGVector(dx: size.width, dy: size.height)
            backgroundSmoke2.advanceSimulationTime(5)
            addChild(backgroundSmoke2)
        }
    }

    fileprivate func setupCreatureCountUI() {
        creatureCountShape.fillColor = .white
        creatureCountShape.alpha = 0.9
        cameraNode.addChild(creatureCountShape)
        creatureCountShape.path = UIBezierPath(
            roundedRect: CGRect(x: -100, y: -30, width: 200, height: 60),
            cornerRadius: 10
        ).cgPath
        creatureCountShape.zPosition = 20
        creatureCountShape.position = CGPoint(x: (frame.size.width / 2) - 120, y: -(frame.size.height / 2) + 80)
        creatureCountLabel.zPosition = 20
        creatureCountLabel.fontColor = .black
        creatureCountShape.addChild(creatureCountLabel)
        creatureCountLabel.position = CGPoint(x: 0, y: -11)
        creatureCountLabel.text = "Alive: 0"
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

// MARK: - Physics Interactions

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if let creatureA = contact.bodyA.node as? AeonCreatureNode,
            let creatureB = contact.bodyB.node as? AeonCreatureNode {
            if creatureA.currentLoveTarget == creatureB, creatureB.currentLoveTarget == creatureA {
                // Mutual reproduction
                creatureA.currentHealth /= 2
                creatureB.currentHealth /= 2
                creatureA.currentLoveTarget = nil
                creatureB.currentLoveTarget = nil
                creatureA.currentState = .nothing
                creatureB.currentState = .nothing
                let newCreature = AeonCreatureNode(withParents: [creatureA, creatureB])
                newCreature.position = creatureA.position
                addChild(newCreature)
                creatureCount += 1
            } else {
                // Determine pursuing creature and give up
                if creatureA.currentLoveTarget == creatureB {
                    let aggressor = creatureA
                    // Remove love target and lose health
                    aggressor.currentHealth /= 2
                    aggressor.currentLoveTarget = nil
                    aggressor.currentState = .nothing
                } else if creatureB.currentLoveTarget == creatureA {
                    let aggressor = creatureB
                    // Remove love target and lose health
                    aggressor.currentHealth /= 2
                    aggressor.currentLoveTarget = nil
                    aggressor.currentState = .nothing
                } else {
                    if creatureA.currentState == .randomMovement {
                        creatureA.currentState = .nothing
                    }
                    if creatureB.currentState == .randomMovement {
                        creatureB.currentState = .nothing
                    }
                }
            }
        }

        if contact.bodyA.categoryBitMask == CollisionTypes.food.rawValue,
            contact.bodyB.categoryBitMask == CollisionTypes.creature.rawValue {
            if let creature = contact.bodyB.node as? AeonCreatureNode,
                let food = contact.bodyA.node as? AeonFoodNode,
                creature.currentState == .movingToFood {
                creature.fed()
                food.eaten()
                foodPelletCount -= 1
            }
        } else if contact.bodyB.categoryBitMask == CollisionTypes.food.rawValue,
            contact.bodyA.categoryBitMask == CollisionTypes.creature.rawValue {
            if let creature = contact.bodyA.node as? AeonCreatureNode,
                let food = contact.bodyB.node as? AeonFoodNode,
                creature.currentState == .movingToFood {
                creature.fed()
                food.eaten()
                foodPelletCount -= 1
            }
        }
    }
}
