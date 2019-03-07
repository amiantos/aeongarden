////
////  AeonCreatureBrain.swift
////  Aeon Garden
////
////  Created by Brad Root on 3/7/19.
////  Copyright © 2019 Brad Root. All rights reserved.
////
//
//import Foundation
//import SpriteKit
//import GameplayKit
//
//protocol AeonCreatureBrainDelegate: class {
//
//}
//
//class AeonCreatureBrain {
//
//
//    public var creature: AeonCreatureNode
//    public var delegate: AeonCreatureBrainDelegate
//
//    private var lastThinkTime: TimeInterval = 0
//
//    public var currentState: State = State.nothing
//    
//    public enum State: String {
//        case nothing = "Thinking"
//        case randomMovement = "Wandering"
//        case locatingFood = "Locating Food"
//        case movingToFood = "Approaching Food"
//        case locatingLove = "Looking for Love"
//        case movingToLove = "Chasing Love"
//        case dead = "Dying"
//    }
//
//    init(withDelegate delegate: AeonCreatureBrainDelegate) {
//        self.delegate = delegate
//    }
//
//    func think(nodes: [SKNode], delta: TimeInterval, time: TimeInterval) {
//
//        // Decide what to do...
//
//        if self.creature.lifeState {
//
//            if self.lastThinkTime == 0 {
//                self.lastThinkTime = time
//            }
//
//            if self.creature.currentHealth <= 100 {
//                if self.currentState != .movingToFood || self.creature.currentFoodTarget == nil || (time - self.lastThinkTime) > 3 {
//                    self.currentState = .locatingFood
//                    self.lastThinkTime = time
//                }
//            } else if self.creature.currentHealth > 250 && self.creature.lifeTime >= 30 {
//                if self.currentState != .movingToLove {
//                    self.currentState = .locatingLove
//                }
//            } else if self.currentState != .randomMovement {
//                self.creature.beginRandomMovement()
//            }
//
//            if self.currentState == .locatingFood {
//                // Decide to eat ...
//                // Remove love target...
//                self.creature.currentLoveTarget = nil
//                // Find closest food node...
//                var foodDistanceArray = [(distance: CGFloat, interesed: Int, node:AeonFoodNode)]()
//                for case let child as AeonFoodNode in nodes {
//                    //if (child.creaturesInterested < 3) {
//                    let distanceComputed = distance(point: child.position)
//                    foodDistanceArray.append((distanceComputed, child.creaturesInterested, child))
//                    //}
//                }
//                foodDistanceArray.sort(by: {$0.distance < $1.distance})
//
//                // Pick first entry...
//
//                if foodDistanceArray.count > 0 {
//                    if let foodTarget = self.currentFoodTarget {
//                        foodTarget.creaturesInterested -= 1
//                    }
//                    self.currentFoodTarget = foodDistanceArray[0].node
//                    foodDistanceArray[0].node.creaturesInterested = foodDistanceArray[0].node.creaturesInterested + 1
//                    self.currentState = .movingToFood
//                }
//            }
//
//            if self.currentState == .locatingLove {
//                // Decide to eat ...
//                // Find furthest creature node...
//                var creatureDifferenceArray = [(speed: CGFloat, distance: CGFloat, node:AeonCreatureNode)]()
//                for case let child as AeonCreatureNode in nodes where (
//                    child != self
//                        && self.parentNames.contains(child.lastName) == false
//                        && child.parentNames.contains(self.lastName) == false) {
//                            let distanceComputed = self.distance(point: child.position)
//                            creatureDifferenceArray.append((child.movementSpeed, distanceComputed, child))
//                }
//
//                creatureDifferenceArray.sort(by: {$0.distance < $1.distance})
//
//                if creatureDifferenceArray.count > 0 {
//                    self.currentLoveTarget = creatureDifferenceArray[0].node
//                    self.currentState = .movingToLove
//                }
//            }
//
//            if self.currentState == .randomMovement {
//                var nodeFound = 0
//                // Check if self is not already at point...
//                if let moveTarget = self.currentMoveTarget {
//                    let nodes = scene!.nodes(at: moveTarget)
//                    for node in nodes where node == self {
//                        nodeFound = 1
//                    }
//                    if nodeFound == 0 {
//                        let moveToPoint = moveTarget
//                        self.move(toCGPoint: moveToPoint)
//                    } else {
//                        self.beginRandomMovement()
//                    }
//                }
//
//            }
//
//            if self.currentState == .movingToFood {
//                var nodeFound = 0
//
//                // Check if node still exists at point...
//                if let foodTarget = self.currentFoodTarget {
//                    let nodes = scene!.nodes(at: foodTarget.position)
//                    for node in nodes where node.name == "aeonFood" {
//                        nodeFound = 1
//                    }
//                    if nodeFound == 1 {
//                        self.move(toCGPoint: foodTarget.position)
//                    } else {
//                        self.currentFoodTarget = nil
//                        self.currentState = .nothing
//                    }
//                }
//
//            }
//
//            if self.currentState == .movingToLove {
//                //self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 0))
//                var nodeFound = 0
//                // Check if node still exists at point...
//                if let loveTarget = self.currentLoveTarget {
//                    let nodes = scene!.nodes(at: loveTarget.position)
//                    for node in nodes {
//                        if node.name == "aeonCreature" && node != self {
//                            nodeFound = 1
//                        }
//                    }
//                    if nodeFound == 1 {
//                        let moveToPoint = loveTarget.position
//                        self.move(toCGPoint: moveToPoint)
//                    } else {
//                        self.currentLoveTarget = nil
//                        self.currentState = .nothing
//                    }
//                }
//
//            }
//
//        }
//
//    }
//
//}
