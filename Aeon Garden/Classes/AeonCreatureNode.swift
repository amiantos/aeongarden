//
//  aeonCreatureNode.swift
//  Aeon Garden
//
//  Created by Bradley Root on 9/30/17.
//  Copyright © 2017 Brad Root. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class AeonCreatureNode: SKNode {

    private var limbOne: SKSpriteNode = SKSpriteNode()
    private var limbTwo: SKSpriteNode = SKSpriteNode()
    private var limbThree: SKSpriteNode = SKSpriteNode()
    private var limbFour: SKSpriteNode = SKSpriteNode()

    // Define colors

    // Decide if dark or light

    public var lightOrDark: Bool

    public var limbOneShape: String = ""
    public var limbTwoShape: String = ""
    public var limbThreeShape: String = ""
    public var limbFourShape: String = ""

    public var limbOneColorHue: CGFloat
    public var limbTwoColorHue: CGFloat
    public var limbThreeColorHue: CGFloat
    public var limbFourColorHue: CGFloat
    public var limbsPrimaryColorHue: CGFloat

    public var limbOneColorBlend: CGFloat = 0
    public var limbTwoColorBlend: CGFloat = 0
    public var limbThreeColorBlend: CGFloat = 0
    public var limbFourColorBlend: CGFloat = 0

    public var limbOneColorBrightness: CGFloat = 0
    public var limbTwoColorBrightness: CGFloat = 0
    public var limbThreeColorBrightness: CGFloat = 0
    public var limbFourColorBrightness: CGFloat = 0

    public var limbOneColorSaturation: CGFloat = 0
    public var limbTwoColorSaturation: CGFloat = 0
    public var limbThreeColorSaturation: CGFloat = 0
    public var limbFourColorSaturation: CGFloat = 0

    public var currentState: State = State.nothing
    public var currentHealth: Float = Float(GKRandomDistribution(lowestValue: 100, highestValue: 250).nextInt()) {
        didSet {
            if currentHealth <= 0 {
                self.die()
            } else if currentHealth > 300 {
                self.currentHealth = 300
            }
        }
    }
    public var currentFoodTarget: AeonFoodNode?
    public var currentLoveTarget: AeonCreatureNode?
    public var currentMoveTarget: CGPoint?
    private var lifeState: Bool = true
    public var lifeTime: Float = 0
    private var movementSpeed: CGFloat = 1
    public var sizeModififer: CGFloat = 1

    private var lastThinkTime: TimeInterval = 0

    public var parentNames: [String] = []

    public let firstName: String
    public let lastName: String

    public enum State: String {
        case nothing = "Thinking"
        case randomMovement = "Wandering"
        case locatingFood = "Locating Food"
        case movingToFood = "Approaching Food"
        case locatingLove = "Looking for Love"
        case movingToLove = "Chasing Love"
        case dead = "Dying"
    }

    public enum BodyPart: String {
        case triangle = "aeonTriangle"
        case circle = "aeonCircle"
        case square = "aeonSquare"
    }

    init(withColorHue: CGFloat?) {

        // Set primary hue for initial creatures...

        if let setColorHue = withColorHue {
            self.limbsPrimaryColorHue = setColorHue
        } else {
            self.limbsPrimaryColorHue = CGFloat(GKRandomDistribution(lowestValue: 1, highestValue: 365).nextInt())
        }

        self.limbOneColorHue = self.limbsPrimaryColorHue + CGFloat(GKRandomDistribution(lowestValue: -20, highestValue: 20).nextInt())
        self.limbTwoColorHue = self.limbsPrimaryColorHue + CGFloat(GKRandomDistribution(lowestValue: -20, highestValue: 20).nextInt())
        self.limbThreeColorHue = self.limbsPrimaryColorHue + CGFloat(GKRandomDistribution(lowestValue: -20, highestValue: 20).nextInt())
        self.limbFourColorHue = self.limbsPrimaryColorHue + CGFloat(GKRandomDistribution(lowestValue: -20, highestValue: 20).nextInt())

        self.lightOrDark = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            return randomBool
        }()

        let nameGenerator = AeonNameGenerator()
        self.firstName = nameGenerator.returnFirstName()
        self.lastName =  nameGenerator.returnLastName()

        super.init()

        self.limbOneColorBrightness = {
            if self.lightOrDark {
                return CGFloat(GKRandomDistribution(lowestValue: 70, highestValue: 100).nextInt())
            } else {
                return CGFloat(GKRandomDistribution(lowestValue: 20, highestValue: 50).nextInt())
            }
        }()
        self.limbTwoColorBrightness = {
            if self.lightOrDark {
                return CGFloat(GKRandomDistribution(lowestValue: 70, highestValue: 100).nextInt())
            } else {
                return CGFloat(GKRandomDistribution(lowestValue: 20, highestValue: 50).nextInt())
            }
        }()
        self.limbThreeColorBrightness = {
            if self.lightOrDark {
                return CGFloat(GKRandomDistribution(lowestValue: 70, highestValue: 100).nextInt())
            } else {
                return CGFloat(GKRandomDistribution(lowestValue: 20, highestValue: 50).nextInt())
            }
        }()
        self.limbFourColorBrightness = {
            if self.lightOrDark {
                return CGFloat(GKRandomDistribution(lowestValue: 70, highestValue: 100).nextInt())
            } else {
                return CGFloat(GKRandomDistribution(lowestValue: 20, highestValue: 50).nextInt())
            }
        }()

        self.limbOneColorSaturation = {
            if self.lightOrDark {
                return CGFloat(GKRandomDistribution(lowestValue: 70, highestValue: 100).nextInt())
            } else {
                return CGFloat(GKRandomDistribution(lowestValue: 20, highestValue: 50).nextInt())
            }
        }()
        self.limbTwoColorSaturation = {
            if self.lightOrDark {
                return CGFloat(GKRandomDistribution(lowestValue: 70, highestValue: 100).nextInt())
            } else {
                return CGFloat(GKRandomDistribution(lowestValue: 20, highestValue: 50).nextInt())
            }
        }()
        self.limbThreeColorSaturation = {
            if self.lightOrDark {
                return CGFloat(GKRandomDistribution(lowestValue: 70, highestValue: 100).nextInt())
            } else {
                return CGFloat(GKRandomDistribution(lowestValue: 20, highestValue: 50).nextInt())
            }
        }()
        self.limbFourColorSaturation = {
            if self.lightOrDark {
                return CGFloat(GKRandomDistribution(lowestValue: 70, highestValue: 100).nextInt())
            } else {
                return CGFloat(GKRandomDistribution(lowestValue: 20, highestValue: 50).nextInt())
            }
        }()

        self.limbOneShape = {
            let randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
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
        }()

        self.limbTwoShape = {
            let randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
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
        }()
        self.limbThreeShape = {
            let randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
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
        }()
        self.limbFourShape = {
            let randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
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
        }()

        self.limbOneColorBlend = {
            if self.lightOrDark {
                return randomFloat(min: 0.3, max: 0.5)
            } else {
                return randomFloat(min: 0.8, max: 1)
            }
        }()
        self.limbTwoColorBlend = {
            if self.lightOrDark {
                return randomFloat(min: 0.3, max: 0.5)
            } else {
                return randomFloat(min: 0.8, max: 1)
            }
        }()
        self.limbThreeColorBlend = {
            if self.lightOrDark {
                return randomFloat(min: 0.3, max: 0.5)
            } else {
                return randomFloat(min: 0.8, max: 1)
            }
        }()
        self.limbFourColorBlend = {
            if self.lightOrDark {
                return randomFloat(min: 0.3, max: 0.5)
            } else {
                return randomFloat(min: 0.8, max: 1)
            }
        }()

        self.movementSpeed = randomFloat(min: 5, max: 10)
        self.sizeModififer = randomFloat(min: 0.7, max: 1.5)

        self.physicsBody = SKPhysicsBody(circleOfRadius: 13)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.categoryBitMask = CollisionTypes.creature.rawValue
        self.physicsBody?.collisionBitMask = CollisionTypes.creature.rawValue | CollisionTypes.food.rawValue
        self.physicsBody?.contactTestBitMask = CollisionTypes.creature.rawValue | CollisionTypes.food.rawValue
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.restitution = 1
        self.physicsBody?.mass = 1
        self.physicsBody?.linearDamping = 0.5
        self.physicsBody?.angularDamping = 0

        /* let sensorPhysicsNode = SKNode()
        sensorPhysicsNode.physicsBody = SKPhysicsBody(circleOfRadius:60)
        sensorPhysicsNode.physicsBody?.categoryBitMask = CollisionTypes.sensor.rawValue
        sensorPhysicsNode.physicsBody?.collisionBitMask = 0
        sensorPhysicsNode.physicsBody?.contactTestBitMask = CollisionTypes.creature.rawValue
        sensorPhysicsNode.physicsBody?.affectedByGravity = false
        sensorPhysicsNode.physicsBody?.isDynamic = true
        sensorPhysicsNode.physicsBody?.pinned = true
        self.addChild(sensorPhysicsNode) */

        // Generate limbs
        limbOne = SKSpriteNode(imageNamed: limbOneShape)
        self.addChild(limbOne)
        limbOne.zRotation = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 10))
        limbOne.zPosition = 2
        limbOne.color = UIColor(
            hue: self.limbOneColorHue/360,
            saturation: self.limbOneColorSaturation/100,
            brightness: self.limbOneColorBrightness/100,
            alpha: 1.0
        )
        limbOne.colorBlendFactor = limbOneColorBlend
        limbOne.position = CGPoint(x: 0, y: GKRandomDistribution(lowestValue: 7, highestValue: 10).nextInt())

        limbTwo = SKSpriteNode(imageNamed: limbTwoShape)
        self.addChild(limbTwo)
        limbTwo.zRotation = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 10))
        limbTwo.zPosition = 2
        limbTwo.color = UIColor(
            hue: self.limbTwoColorHue/360,
            saturation: self.limbTwoColorSaturation/100,
            brightness: self.limbTwoColorBrightness/100,
            alpha: 1.0
        )
        limbTwo.colorBlendFactor = limbTwoColorBlend
        limbTwo.position = CGPoint(x: GKRandomDistribution(lowestValue: 7, highestValue: 10).nextInt(), y: 0)

        limbThree = SKSpriteNode(imageNamed: limbThreeShape)
        self.addChild(limbThree)
        limbThree.zRotation = CGFloat(GKRandomDistribution(lowestValue: 7, highestValue: 10).nextInt())
        limbThree.zPosition = 2
        limbThree.color = UIColor(
            hue: self.limbThreeColorHue/360,
            saturation: self.limbThreeColorSaturation/100,
            brightness: self.limbThreeColorBrightness/100,
            alpha: 1.0
        )
        limbThree.colorBlendFactor = limbThreeColorBlend
        limbThree.position = CGPoint(x: 0, y: -GKRandomDistribution(lowestValue: 7, highestValue: 10).nextInt())

        limbFour = SKSpriteNode(imageNamed: limbFourShape)
        self.addChild(limbFour)
        limbFour.zRotation = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 10))
        limbFour.zPosition = 2
        limbFour.color = UIColor(
            hue: self.limbFourColorHue/360,
            saturation: self.limbFourColorSaturation/100,
            brightness: self.limbFourColorBrightness/100,
            alpha: 1.0
        )
        limbFour.colorBlendFactor = limbFourColorBlend
        limbFour.position = CGPoint(x: -GKRandomDistribution(lowestValue: 5, highestValue: 8).nextInt(), y: 0)

        let underShadow = SKSpriteNode(imageNamed: "aeonBodyShadow")
        underShadow.setScale(1.2)
        underShadow.alpha = 0.2
        self.addChild(underShadow)

        self.name = "aeonCreature"

        self.birth()
        self.beginWiggling()

    }

    init(parent: AeonCreatureNode, parent2: AeonCreatureNode) {

        self.lightOrDark = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.lightOrDark
            } else {
                return parent2.lightOrDark
            }
        }()

        self.limbOneColorHue = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbOneColorHue //+ CGFloat(GKRandomDistribution(lowestValue: -50, highestValue: 50).nextInt())
            } else {
                return parent2.limbOneColorHue //+ CGFloat(GKRandomDistribution(lowestValue: -50, highestValue: 50).nextInt())
            }
        }()
        self.limbTwoColorHue = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbTwoColorHue //+ CGFloat(GKRandomDistribution(lowestValue: -50, highestValue: 50).nextInt())
            } else {
                return parent2.limbTwoColorHue //+ CGFloat(GKRandomDistribution(lowestValue: -50, highestValue: 50).nextInt())
            }
        }()
        self.limbThreeColorHue = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbThreeColorHue //+ CGFloat(GKRandomDistribution(lowestValue: -50, highestValue: 50).nextInt())
            } else {
                return parent2.limbThreeColorHue //+ CGFloat(GKRandomDistribution(lowestValue: -50, highestValue: 50).nextInt())
            }
        }()
        self.limbFourColorHue = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbFourColorHue //+ CGFloat(GKRandomDistribution(lowestValue: -50, highestValue: 50).nextInt())
            } else {
                return parent2.limbFourColorHue //+ CGFloat(GKRandomDistribution(lowestValue: -50, highestValue: 50).nextInt())
            }
        }()

        self.limbOneColorBlend = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbOneColorBlend
            } else {
                return parent2.limbOneColorBlend
            }
        }()
        self.limbTwoColorBlend = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbTwoColorBlend
            } else {
                return parent2.limbTwoColorBlend
            }
        }()
        self.limbThreeColorBlend = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbThreeColorBlend
            } else {
                return parent2.limbThreeColorBlend
            }
        }()
        self.limbFourColorBlend = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbFourColorBlend
            } else {
                return parent2.limbFourColorBlend
            }
        }()

         self.limbsPrimaryColorHue = (self.limbOneColorHue + self.limbTwoColorHue + self.limbThreeColorHue + self.limbFourColorHue)/4

        let nameGenerator = AeonNameGenerator()
        self.firstName = nameGenerator.returnFirstName()
        self.lastName = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.lastName
            } else {
                return parent2.lastName
            }
        }()

        super.init()

            /*for lastName in parent.parentNames {
                self.parentNames.append(lastName)
            }
        
        

            for lastName in parent2.parentNames {
                self.parentNames.append(lastName)
            }*/

        self.parentNames.append(parent.lastName)
        self.parentNames.append(parent2.lastName)

        self.movementSpeed = {
            let randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: 7)

            switch randomNumber {
            case 0:
                return parent.movementSpeed
            case 1:
                return parent2.movementSpeed
            case 2:
                return (parent.movementSpeed+parent2.movementSpeed)/2
            case 3:
                return parent.movementSpeed*1.01
            case 4:
                return parent2.movementSpeed*1.01
            case 5:
                return parent.movementSpeed*0.99
            case 6:
                return parent2.movementSpeed*0.99
            default:
                return (parent.movementSpeed+parent2.movementSpeed)/2
            }
        }()
        self.sizeModififer = {
            let randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: 7)

            switch randomNumber {
            case 0:
                return parent.sizeModififer
            case 1:
                return parent2.sizeModififer
            case 2:
                return (parent.sizeModififer+parent2.sizeModififer)/2
            case 3:
                return parent.sizeModififer*1.01
            case 4:
                return parent2.sizeModififer*1.01
            case 5:
                return parent.sizeModififer*0.99
            case 6:
                return parent2.sizeModififer*0.99
            default:
                return (parent.sizeModififer+parent2.sizeModififer)/2
            }
        }()

        self.physicsBody = SKPhysicsBody(circleOfRadius: 13)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.categoryBitMask = CollisionTypes.creature.rawValue
        self.physicsBody?.collisionBitMask = CollisionTypes.creature.rawValue | CollisionTypes.food.rawValue
        self.physicsBody?.contactTestBitMask = CollisionTypes.creature.rawValue | CollisionTypes.food.rawValue
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.restitution = 1
        self.physicsBody?.mass = 1
        self.physicsBody?.linearDamping = 0.5
        self.physicsBody?.angularDamping = 0

        /*
         let sensorPhysicsNode = SKNode()
        sensorPhysicsNode.physicsBody = SKPhysicsBody(circleOfRadius:40)
        sensorPhysicsNode.physicsBody?.categoryBitMask = CollisionTypes.sensor.rawValue
        sensorPhysicsNode.physicsBody?.collisionBitMask = 0
        sensorPhysicsNode.physicsBody?.contactTestBitMask = CollisionTypes.creature.rawValue
        sensorPhysicsNode.physicsBody?.affectedByGravity = false
        sensorPhysicsNode.physicsBody?.isDynamic = true
        sensorPhysicsNode.physicsBody?.pinned = true
        self.addChild(sensorPhysicsNode)
 */

        // Define colors

        limbOneShape = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbOneShape
            } else {
                return parent2.limbOneShape
            }
            }()
        limbTwoShape = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbTwoShape
            } else {
                return parent2.limbTwoShape
            }
        }()
        limbThreeShape = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbThreeShape
            } else {
                return parent2.limbThreeShape
            }
        }()
        limbFourShape = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbFourShape
            } else {
                return parent2.limbFourShape
            }
        }()

        limbOneColorBrightness = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbOneColorBrightness
            } else {
                return parent2.limbOneColorBrightness
            }
        }()
        limbTwoColorBrightness = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbTwoColorBrightness
            } else {
                return parent2.limbTwoColorBrightness
            }
        }()
        limbThreeColorBrightness = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbThreeColorBrightness
            } else {
                return parent2.limbThreeColorBrightness
            }
        }()
        limbFourColorBrightness = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbFourColorBrightness
            } else {
                return parent2.limbFourColorBrightness
            }
        }()

        limbOneColorSaturation = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbOneColorSaturation
            } else {
                return parent2.limbOneColorSaturation
            }
        }()
        limbTwoColorSaturation = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbTwoColorSaturation
            } else {
                return parent2.limbTwoColorSaturation
            }
        }()
        limbThreeColorSaturation = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbThreeColorSaturation
            } else {
                return parent2.limbThreeColorSaturation
            }
        }()
        limbFourColorSaturation = {
            let randomBool = GKRandomSource.sharedRandom().nextBool()
            if randomBool {
                return parent.limbFourColorSaturation
            } else {
                return parent2.limbFourColorSaturation
            }
        }()

        // Generate limbs
        limbOne = SKSpriteNode(imageNamed: limbOneShape)
        self.addChild(limbOne)
        limbOne.zRotation = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 10))
        limbOne.zPosition = 2
        limbOne.color = UIColor(
            hue: limbOneColorHue/360,
            saturation: limbOneColorSaturation/100,
            brightness: limbOneColorBrightness/100,
            alpha: 1.0
        )
        limbOne.colorBlendFactor = 0.75
        limbOne.position = CGPoint(x: 0, y: GKRandomDistribution(lowestValue: 7, highestValue: 10).nextInt())

        limbTwo = SKSpriteNode(imageNamed: limbTwoShape)
        self.addChild(limbTwo)
        limbTwo.zRotation = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 10))
        limbTwo.zPosition = 2
        limbTwo.color = UIColor(
            hue: limbTwoColorHue/360,
            saturation: limbTwoColorSaturation/100,
            brightness: limbTwoColorBrightness/100,
            alpha: 1.0
        )
        limbTwo.colorBlendFactor = 0.5
        limbTwo.position = CGPoint(x: GKRandomDistribution(lowestValue: 7, highestValue: 10).nextInt(), y: 0)

        limbThree = SKSpriteNode(imageNamed: limbThreeShape)
        self.addChild(limbThree)
        limbThree.zRotation = CGFloat(GKRandomDistribution(lowestValue: 7, highestValue: 10).nextInt())
        limbThree.zPosition = 2
        limbThree.color = UIColor(
            hue: limbThreeColorHue/360,
            saturation: limbThreeColorSaturation/100,
            brightness: limbThreeColorBrightness/100,
            alpha: 1.0
        )
        limbThree.colorBlendFactor = 0.5
        limbThree.position = CGPoint(x: 0, y: -GKRandomDistribution(lowestValue: 7, highestValue: 10).nextInt())

        limbFour = SKSpriteNode(imageNamed: limbFourShape)
        self.addChild(limbFour)
        limbFour.zRotation = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 10))
        limbFour.zPosition = 2
        limbFour.color = UIColor(
            hue: limbFourColorHue/360,
            saturation: limbFourColorSaturation/100,
            brightness: limbFourColorBrightness/100,
            alpha: 1.0
        )
        limbFour.colorBlendFactor = 0.5
        limbFour.position = CGPoint(x: -GKRandomDistribution(lowestValue: 5, highestValue: 8).nextInt(), y: 0)

        let underShadow = SKSpriteNode(imageNamed: "aeonBodyShadow")
        underShadow.setScale(1.2)
        underShadow.alpha = 0.2
        self.addChild(underShadow)

        self.name = "aeonCreature"

        self.birth()
        self.beginWiggling()

    }

    func think(nodes: [SKNode], delta: TimeInterval, time: TimeInterval) {

        // Decide what to do...

        if self.lifeState {

            if self.lastThinkTime == 0 {
                self.lastThinkTime = time
            }

            if self.currentHealth <= 100 {
                if self.currentState != .movingToFood || self.currentFoodTarget == nil || (time - self.lastThinkTime) > 3 {
                    self.currentState = .locatingFood
                    self.lastThinkTime = time
                }
            } else if self.currentHealth > 250 && self.lifeTime >= 30 {
                if self.currentState != .movingToLove {
                    self.currentState = .locatingLove
                }
            } else if self.currentState != .randomMovement {
                self.beginRandomMovement()
            }

            if self.currentState == .locatingFood {
                // Decide to eat ...
                // Remove love target...
                self.currentLoveTarget = nil
                // Find closest food node...
                var foodDistanceArray = [(distance: CGFloat, interesed: Int, node:AeonFoodNode)]()
                for case let child as AeonFoodNode in nodes {
                    //if (child.creaturesInterested < 3) {
                        let distanceComputed = distance(point: child.position)
                        foodDistanceArray.append((distanceComputed, child.creaturesInterested, child))
                    //}
                }
                foodDistanceArray.sort(by: {$0.distance < $1.distance})

                // Pick first entry...

                if foodDistanceArray.count > 0 {
                    if let foodTarget = self.currentFoodTarget {
                        foodTarget.creaturesInterested -= 1
                    }
                    self.currentFoodTarget = foodDistanceArray[0].node
                    foodDistanceArray[0].node.creaturesInterested = foodDistanceArray[0].node.creaturesInterested + 1
                    self.currentState = .movingToFood
                }
            }

            if self.currentState == .locatingLove {
                // Decide to eat ...
                // Find furthest creature node...
                var creatureDifferenceArray = [(speed: CGFloat, distance: CGFloat, node:AeonCreatureNode)]()
                for case let child as AeonCreatureNode in nodes where (child != self && self.parentNames.contains(child.lastName) == false && child.parentNames.contains(self.lastName) == false) {
                    let distanceComputed = self.distance(point: child.position)
                    creatureDifferenceArray.append((child.movementSpeed, distanceComputed, child))
                }

                creatureDifferenceArray.sort(by: {$0.distance < $1.distance})

                if creatureDifferenceArray.count > 0 {
                    self.currentLoveTarget = creatureDifferenceArray[0].node
                    self.currentState = .movingToLove
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
                        self.move(toCGPoint: moveToPoint)
                    } else {
                        self.beginRandomMovement()
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
                        self.move(toCGPoint: foodTarget.position)
                    } else {
                        self.currentFoodTarget = nil
                        self.currentState = .nothing
                    }
                }

            }

            if self.currentState == .movingToLove {
                //self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 0))
                var nodeFound = 0
                // Check if node still exists at point...
                if let loveTarget = self.currentLoveTarget {
                    let nodes = scene!.nodes(at: loveTarget.position)
                    for node in nodes {
                        if node.name == "aeonCreature" && node != self {
                            nodeFound = 1
                        }
                    }
                    if nodeFound == 1 {
                        let moveToPoint = loveTarget.position
                        self.move(toCGPoint: moveToPoint)
                    } else {
                        self.currentLoveTarget = nil
                        self.currentState = .nothing
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
                rotationDuration = abs(self.zRotation - angleMovement)*2.5
            } else if self.zRotation < angleMovement {
                rotationDuration = abs(angleMovement - self.zRotation)*2.5
            }

            if rotationDuration > 6 { rotationDuration = 6 }

            let rotationAction = SKAction.rotate(toAngle: angleMovement, duration: TimeInterval(rotationDuration), shortestUnitArc: true)

            rotationAction.timingMode = .easeInEaseOut

            self.run(rotationAction, withKey: "Rotating")
        }

        let radianFactor: CGFloat = 0.0174532925
        let rotationInDegrees = self.zRotation / radianFactor
        let newRotationDegrees = rotationInDegrees + 90
        let newRotationRadians = newRotationDegrees * radianFactor

        let thrustVector: CGVector = CGVector(dx: cos(newRotationRadians) * self.movementSpeed, dy: sin(newRotationRadians) * self.movementSpeed)

        self.physicsBody?.applyForce(thrustVector)

    }

    func beginRandomMovement() {
        let positionX = CGFloat(GKRandomDistribution(lowestValue: 0, highestValue: Int(scene!.size.width)).nextInt())
        let positionY = CGFloat(GKRandomDistribution(lowestValue: 0, highestValue: Int(scene!.size.height)).nextInt())
        let moveToPoint = CGPoint.init(x: positionX, y: positionY)
        self.currentMoveTarget = moveToPoint
        self.currentState = .randomMovement
    }

    func randomFloat(min: CGFloat, max: CGFloat) -> CGFloat {
        return (CGFloat(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }

    func angleBetweenPointOne(pointOne: CGPoint, andPointTwo pointTwo: CGPoint) -> CGFloat {
        let xdiff = (pointTwo.x - pointOne.x)
        let ydiff = (pointTwo.y - pointOne.y)
        let rad = atan2(ydiff, xdiff)
        return rad - 1.5707963268       // convert from atan's right-pointing zero to CG's up-pointing zero
    }

    func distance(point: CGPoint) -> CGFloat {
        return CGFloat(hypotf(Float(point.x - self.position.x), Float(point.y - self.position.y)))
    }

    func birth() {

        self.setScale(0.1)
        //self.setScale(self.sizeModififer)
        let birthAction = SKAction.scale(to: self.sizeModififer, duration: 30)
        self.run(birthAction)

        //print(self.parentNames)
    }

    func die() {
        // Creature dies...

        self.removeAllActions()
        //self.physicsBody = nil
        self.physicsBody!.contactTestBitMask = 0
        self.lifeState = false
        self.endWiggling()

        // Remove interested creature from food target
        if let foodTarget = self.currentFoodTarget {
            foodTarget.creaturesInterested -= 1
        }

        //self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
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

    func ate() {
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
            let wiggleAction = SKAction.rotate(byAngle: CGFloat(wiggleFactor), duration: TimeInterval(GKRandomSource.sharedRandom().nextUniform()))
            let wiggleActionBack = SKAction.rotate(byAngle: CGFloat(-wiggleFactor), duration: TimeInterval(GKRandomSource.sharedRandom().nextUniform()))

            let wiggleMoveFactor = GKRandomSource.sharedRandom().nextUniform()
            let wiggleMoveFactor2 = GKRandomSource.sharedRandom().nextUniform()

            let wiggleMovement = SKAction.moveBy(x: CGFloat(wiggleMoveFactor), y: CGFloat(wiggleMoveFactor2), duration: TimeInterval(GKRandomSource.sharedRandom().nextUniform()))
            let wiggleMovementBack = SKAction.moveBy(x: CGFloat(-wiggleMoveFactor), y: CGFloat(-wiggleMoveFactor2), duration: TimeInterval(GKRandomSource.sharedRandom().nextUniform()))

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
        if lastUpdate < 10 && self.currentHealth > 0 {
            // if state is not sleeping, lose health...
            self.currentHealth -= Float(lastUpdate)
            self.lifeTime += Float(lastUpdate)
        }
    }

    func ageWithoutDeath(lastUpdate: TimeInterval) {
        if lastUpdate < 10 && self.currentHealth > 0 {
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

        let aeonDays: Double = round(Double(lifeTime/60) * 10) / 10
        let aeonYears: Double = round(aeonDays/60 * 10) / 10

        if aeonDays < 60 {
            return "\(aeonDays) Minutes Old"
        } else {
            return "\(aeonYears) Hours Old"
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
