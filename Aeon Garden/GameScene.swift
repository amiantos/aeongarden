//
//  GameScene.swift
//  Aeon Garden
//
//  Created by Bradley Root on 9/30/17.
//  Copyright © 2017 Brad Root. All rights reserved.
//

import SpriteKit
import GameplayKit

enum CollisionTypes: UInt32 {
    case creature = 1
    case food = 2
    case edge = 4
    case sensor = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    public var foodPelletCount: Int = 0
    private var foodPelletMax: Int = 20
    public var creatureCount: Int = 0
    private var creatureMax: Int = 20
    
    private var lastUpdateTime : TimeInterval = 0
    private var lastFoodTime : TimeInterval = 0
    private var lastThinkTime : TimeInterval = 0
    private var lastCreatureTime : TimeInterval = 0
    
    private var creatureCountLabel = SKLabelNode(fontNamed: "Helvetica-Light")
    private let creatureCountShape = SKShapeNode(rect: CGRect(x: 0, y: -100, width: 200, height: 60))
    
    private let creatureStatsNode = SKSpriteNode(imageNamed: "aeonStatsLine")
    private var nameLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
    private var lifeTimeLabel = SKLabelNode(fontNamed: "Helvetica-Light")
    private var healthLabel = SKLabelNode(fontNamed: "Helvetica-Light")
    private var currentStatusLabel = SKLabelNode(fontNamed: "Helvetica-Light")
    
    var selectedCreature: AeonCreatureNode? {
        didSet {
            if (oldValue != selectedCreature) {
                self.creatureStatsNode.removeAllActions()
                self.creatureStatsNode.alpha = 0
            }
            if (selectedCreature == nil) {
                self.creatureStatsNode.removeAllActions()
                self.creatureStatsNode.alpha = 0
                let zoomInAction = SKAction.scale(to: 1, duration: 1)
                let cameraAction = SKAction.move(to: CGPoint(x: self.size.width / 2, y: self.size.height / 2), duration: 1)
                camera?.run(SKAction.group([zoomInAction,cameraAction]))
            }
        }
    }
    
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
    }
    
    override func sceneDidLoad() {
        
        
        self.size.width = frame.size.width * 2
        self.size.height = frame.size.height * 2
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionTypes.edge.rawValue
        self.physicsBody?.friction = 0
        
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(cameraNode)
        self.camera = cameraNode
        
        if let backgroundSmoke = SKEmitterNode(fileNamed: "AeonSmokeParticle.sks") {
            backgroundSmoke.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            backgroundSmoke.zPosition = -2
            backgroundSmoke.particlePositionRange = CGVector(dx: self.size.width, dy: self.size.height)
            backgroundSmoke.advanceSimulationTime(5)
            self.addChild(backgroundSmoke)
        }
        if let backgroundSmoke2 = SKEmitterNode(fileNamed: "AeonOceanSparkle.sks") {
            backgroundSmoke2.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            backgroundSmoke2.zPosition = -1
            backgroundSmoke2.particlePositionRange = CGVector(dx: self.size.width, dy: self.size.height)
            backgroundSmoke2.advanceSimulationTime(5)
            self.addChild(backgroundSmoke2)
        }
        
        var totalCreatures: Int = 0
        var initialCreatureHue: CGFloat = 0
        let colorHueIncrement: CGFloat = CGFloat(360/creatureMax)
        
        while (totalCreatures < creatureMax) {
            
            let aeonCreature = AeonCreatureNode(withColorHue: initialCreatureHue)
            let foodPositionX = CGFloat(GKRandomDistribution(lowestValue: Int(self.size.width*0.10), highestValue: Int(self.size.width*0.90)).nextInt())
            let foodPositionY = CGFloat(GKRandomDistribution(lowestValue: Int(self.size.height*0.10), highestValue: Int(self.size.height*0.90)).nextInt())
            aeonCreature.position = CGPoint(x: foodPositionX, y: foodPositionY)
            aeonCreature.zRotation = CGFloat(GKRandomDistribution(lowestValue: 0, highestValue: 10).nextInt())
            aeonCreature.zPosition = 12
            addChild(aeonCreature)
            self.creatureCount = self.creatureCount + 1

            totalCreatures = totalCreatures + 1
            initialCreatureHue = initialCreatureHue + colorHueIncrement
        }
        
        self.creatureCountShape.fillColor = .white
        self.creatureCountShape.alpha = 0.9
        cameraNode.addChild(self.creatureCountShape)
        self.creatureCountShape.path = UIBezierPath(roundedRect: CGRect(x: -100, y: -30, width: 200, height: 60), cornerRadius: 10).cgPath
        self.creatureCountShape.zPosition = 20
        self.creatureCountShape.position = CGPoint(x: -(frame.size.width/2)+160, y: (frame.size.height/2)-80)
        self.creatureCountLabel.zPosition = 20
        self.creatureCountLabel.fontColor = .black
        self.creatureCountShape.addChild(creatureCountLabel)
        self.creatureCountLabel.position = CGPoint(x: 0, y: -11)
        self.creatureCountLabel.text = "Alive: 0"
        
        cameraNode.addChild(creatureStatsNode)
        self.creatureStatsNode.alpha = 0
        self.creatureStatsNode.size.width = self.creatureStatsNode.size.width / 1.2
        self.creatureStatsNode.position.x = (self.creatureStatsNode.size.width / 2.2)
        
        self.creatureStatsNode.addChild(nameLabel)
        self.nameLabel.position.x = 0
        self.nameLabel.position.y = 15
        self.nameLabel.alpha = 0.5
        self.nameLabel.horizontalAlignmentMode = .center
        self.nameLabel.verticalAlignmentMode = .bottom
        
        self.creatureStatsNode.addChild(lifeTimeLabel)
        self.lifeTimeLabel.position.x = 0
        self.lifeTimeLabel.position.y = -16
        self.lifeTimeLabel.fontSize = 25
        self.lifeTimeLabel.alpha = 0.3
        self.lifeTimeLabel.horizontalAlignmentMode = .center
        self.lifeTimeLabel.verticalAlignmentMode = .top
        
        self.creatureStatsNode.addChild(currentStatusLabel)
        self.currentStatusLabel.position.x = 0
        self.currentStatusLabel.position.y = -50
        self.currentStatusLabel.fontSize = 25
        self.currentStatusLabel.alpha = 0.3
        self.currentStatusLabel.horizontalAlignmentMode = .center
        self.currentStatusLabel.verticalAlignmentMode = .top
        
        self.creatureStatsNode.addChild(healthLabel)
        self.healthLabel.position.x = 0
        self.healthLabel.position.y = -86
        self.healthLabel.fontSize = 25
        self.healthLabel.alpha = 0.3
        self.healthLabel.horizontalAlignmentMode = .center
        self.healthLabel.verticalAlignmentMode = .top
        
       
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
    
        
        if let creatureA = contact.bodyA.node as? AeonCreatureNode, let creatureB = contact.bodyB.node as? AeonCreatureNode {
            if (creatureA.currentLoveTarget == creatureB && creatureB.currentLoveTarget == creatureA) {
                // Fuck
                creatureA.currentHealth = creatureA.currentHealth / 2
                creatureB.currentHealth = creatureB.currentHealth / 2 
                creatureA.currentLoveTarget = nil
                creatureB.currentLoveTarget = nil
                creatureA.currentState = .nothing
                creatureB.currentState = .nothing
                let newCreature = AeonCreatureNode(parent: creatureA, parent2: creatureB)
                newCreature.position = creatureA.position
                self.addChild(newCreature)
                self.creatureCount = self.creatureCount + 1
            } else {
                // Determine pursuing creature and give up
                if (creatureA.currentLoveTarget == creatureB) {
                    let aggressor = creatureA
                    // Remove love target...
                    aggressor.currentHealth = aggressor.currentHealth / 2
                    aggressor.currentLoveTarget = nil
                    aggressor.currentState = .nothing
                } else if (creatureB.currentLoveTarget == creatureA) {
                    let aggressor = creatureB
                    // Remove love target...
                    aggressor.currentHealth = aggressor.currentHealth / 2
                    aggressor.currentLoveTarget = nil
                    aggressor.currentState = .nothing
                } else {
                    if (creatureA.currentState == .randomMovement) {
                        creatureA.currentState = .nothing
                    }
                    
                    if (creatureB.currentState == .randomMovement) {
                        creatureB.currentState = .nothing
                    }
                }
            }
        }
        
        if (contact.bodyA.categoryBitMask == CollisionTypes.sensor.rawValue && contact.bodyB.categoryBitMask == CollisionTypes.creature.rawValue) {
            if let creature = contact.bodyA.node?.parent as? AeonCreatureNode {
                if (creature.currentState == .randomMovement) {
                    creature.currentState = .nothing
                }
            }
            
        } else if (contact.bodyB.categoryBitMask == CollisionTypes.sensor.rawValue && contact.bodyA.categoryBitMask == CollisionTypes.creature.rawValue) {
            if let creature = contact.bodyB.node?.parent as? AeonCreatureNode {
                if (creature.currentState == .randomMovement) {
                    creature.currentState = .nothing
                }
            }
        }
        
        
        if (contact.bodyA.categoryBitMask == CollisionTypes.food.rawValue && contact.bodyB.categoryBitMask == CollisionTypes.creature.rawValue) {
            if let creature = contact.bodyB.node as? AeonCreatureNode, let food = contact.bodyA.node as? AeonFoodNode {
                if (creature.currentState == .movingToFood) {
                    creature.ate()
                    food.bitten()
                    self.foodPelletCount = self.foodPelletCount-1
                }
            }
        } else if (contact.bodyB.categoryBitMask == CollisionTypes.food.rawValue && contact.bodyA.categoryBitMask == CollisionTypes.creature.rawValue) {
            if let creature = contact.bodyA.node as? AeonCreatureNode, let food = contact.bodyB.node as? AeonFoodNode {
                if (creature.currentState == .movingToFood) {
                    creature.ate()
                    food.bitten()
                    self.foodPelletCount = self.foodPelletCount-1
                }
            }
        }
        
 
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
       
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
        
        let touch = touches.first!
        let touchPoint = touch.location(in: self)
        let nodes = self.nodes(at: touchPoint)
        for node in nodes {
            if (node.name == "aeonCreature") {
                print("Creature Tapped")
                if (node == selectedCreature) {
                    self.selectedCreature = nil
                    camera?.removeAllActions()
                    let zoomInAction = SKAction.scale(to: 1, duration: 1)
                    let cameraAction = SKAction.move(to: CGPoint(x: self.size.width / 2, y: self.size.height / 2), duration: 1)
                    camera?.run(SKAction.group([zoomInAction,cameraAction]))
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
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Update camera to follow selected creature...
        if let followCreature = self.selectedCreature {
            let cameraAction = SKAction.move(to: followCreature.position, duration: 0.25)
            camera?.run(cameraAction)
            self.nameLabel.text = followCreature.firstName + " " + followCreature.lastName
            self.lifeTimeLabel.text = followCreature.lifeTimeFormattedAsString()
            self.currentStatusLabel.text = followCreature.currentState.rawValue
            //self.healthLabel.text = "Health: \(Int(followCreature.currentHealth))"
        }
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
            self.lastFoodTime = currentTime
            self.lastThinkTime = currentTime
            self.lastCreatureTime = currentTime
        }
        
        let dt = currentTime - lastUpdateTime
        
        
       if ((currentTime - self.lastFoodTime) > 2) {
            
            if (self.foodPelletCount < self.foodPelletMax) {
                let aeonFood = AeonFoodNode()
                
                if let selectedCreaturePosition = self.selectedCreature?.position, GKRandomDistribution.d20().nextInt() > 10 {
                    let foodPositionX = selectedCreaturePosition.x + CGFloat(GKRandomDistribution(lowestValue: -300, highestValue: 300).nextInt())
                    let foodPositionY = selectedCreaturePosition.y + CGFloat(GKRandomDistribution(lowestValue: -300, highestValue: 300).nextInt())
                    aeonFood.position = CGPoint(x: foodPositionX, y: foodPositionY)
                } else {
                    let foodPositionX = CGFloat(GKRandomDistribution(lowestValue: Int(self.size.width*0.01), highestValue: Int(self.size.width*0.99)).nextInt())
                    let foodPositionY = CGFloat(GKRandomDistribution(lowestValue: Int(self.size.height*0.01), highestValue: Int(self.size.height*0.99)).nextInt())
                    aeonFood.position = CGPoint(x: foodPositionX, y: foodPositionY)
                }
               
                
                
                
                aeonFood.zRotation = CGFloat(GKRandomDistribution(lowestValue: 0, highestValue: 10).nextInt())
                addChild(aeonFood)
                self.foodPelletCount = self.foodPelletCount + 1
            }
        
        
            self.lastFoodTime = currentTime
        }
        
        if ((currentTime - self.lastCreatureTime) > 600) {
            
            let aeonCreature = AeonCreatureNode(withColorHue: nil)
            let foodPositionX = CGFloat(GKRandomDistribution(lowestValue: Int(self.size.width*0.10), highestValue: Int(self.size.width*0.90)).nextInt())
            let foodPositionY = CGFloat(GKRandomDistribution(lowestValue: Int(self.size.height*0.10), highestValue: Int(self.size.height*0.90)).nextInt())
            aeonCreature.position = CGPoint(x: foodPositionX, y: foodPositionY)
            aeonCreature.zRotation = CGFloat(GKRandomDistribution(lowestValue: 0, highestValue: 10).nextInt())
            aeonCreature.zPosition = 12
            addChild(aeonCreature)
            self.creatureCount = self.creatureCount + 1
            
            self.lastCreatureTime = currentTime
        }

        self.creatureCountLabel.text = "Alive: \(self.creatureCount)"
        
        for case let child as AeonCreatureNode in self.children {
            child.think(nodes: self.children, delta: dt, time: currentTime)
            child.age(lastUpdate: dt)
        }
        
        for case let child as AeonFoodNode in self.children {
            child.age(lastUpdate: dt)
        }
        
        
        self.lastUpdateTime = currentTime
    }
}
