//
//  AeonCreatureBrain.swift
//  Aeon Garden
//
//  Created by Brad Root on 3/7/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

protocol AeonCreatureBrainDelegate: class {
    var currentHealth: Float { get set }
    var lifeTime: Float { get set }
    var lastName: String { get set }
    var parentNames: [String] { get set }

    func beginRandomMovement()
    func distance(point: CGPoint) -> CGFloat

    func getNodes(atPosition position: CGPoint) -> [SKNode]
    func getNodes() -> [SKNode]

    func move(toCGPoint: CGPoint)
}

class AeonCreatureBrain {
    weak var delegate: AeonCreatureBrainDelegate?

    public var currentState: State = State.nothing
    public var currentFoodTarget: AeonFoodNode?
    public var currentLoveTarget: AeonCreatureNode?
    public var currentMoveTarget: CGPoint?
    public var lastThinkTime: TimeInterval = 0
    public var lifeState: Bool = true

    public enum State: String {
        case nothing = "Thinking"
        case randomMovement = "Wandering"
        case locatingFood = "Locating Food"
        case movingToFood = "Approaching Food"
        case locatingLove = "Looking for Love"
        case movingToLove = "Chasing Love"
        case dead = "Dying"
    }

    // MARK: - Thought Process

    fileprivate func locateLove() {
        var creatureDifferenceArray = [(speed: CGFloat, distance: CGFloat, node: AeonCreatureNode)]()
        let nodes = delegate!.getNodes()
        for case let child as AeonCreatureNode in nodes where
            child != delegate as? AeonCreatureNode
            && delegate!.parentNames.contains(child.lastName) == false
            && child.parentNames.contains(delegate!.lastName) == false {
            let distanceComputed = delegate!.distance(point: child.position)
            creatureDifferenceArray.append((child.movementSpeed, distanceComputed, child))
        }

        creatureDifferenceArray.sort(by: { $0.distance < $1.distance })

        if creatureDifferenceArray.count > 0 {
            currentLoveTarget = creatureDifferenceArray[0].node
            currentState = .movingToLove
        }
    }

    fileprivate func moveToLove() {
        var nodeFound = 0
        // Check if node still exists at point...
        if let loveTarget = currentLoveTarget {
            let nodes = delegate!.getNodes(atPosition: loveTarget.position)
            for node in nodes where node.name == "aeonCreature" && node != delegate as? AeonCreatureNode {
                nodeFound = 1
            }
            if nodeFound == 1 {
                let moveToPoint = loveTarget.position
                delegate!.move(toCGPoint: moveToPoint)
            } else {
                currentLoveTarget = nil
                currentState = .nothing
            }
        }
    }

    fileprivate func locateFood() {
        currentLoveTarget = nil
        var foodDistanceArray = [(distance: CGFloat, interesed: Int, node: AeonFoodNode)]()
        let nodes = delegate!.getNodes()
        for case let child as AeonFoodNode in nodes {
            let distanceComputed = delegate!.distance(point: child.position)
            foodDistanceArray.append((distanceComputed, child.creaturesInterested, child))
        }
        foodDistanceArray.sort(by: { $0.distance < $1.distance })

        if foodDistanceArray.count > 0 {
            if let foodTarget = self.currentFoodTarget {
                foodTarget.creaturesInterested -= 1
            }
            currentFoodTarget = foodDistanceArray[0].node
            foodDistanceArray[0].node.creaturesInterested = foodDistanceArray[0].node.creaturesInterested + 1
            currentState = .movingToFood
        }
    }

    fileprivate func moveToFood() {
        var nodeFound = 0
        if let foodTarget = self.currentFoodTarget {
            let nodes = delegate!.getNodes(atPosition: foodTarget.position)
            for node in nodes where node.name == "aeonFood" {
                nodeFound = 1
            }
            if nodeFound == 1 {
                delegate!.move(toCGPoint: foodTarget.position)
            } else {
                currentFoodTarget = nil
                currentState = .nothing
            }
        }
    }

    fileprivate func moveRandomly() {
        var nodeFound = 0
        // Check if self is not already at point...
        if let moveTarget = self.currentMoveTarget {
            let nodes = delegate!.getNodes(atPosition: moveTarget)
            for node in nodes where node == delegate as? AeonCreatureNode {
                nodeFound = 1
            }
            if nodeFound == 0 {
                let moveToPoint = moveTarget
                delegate!.move(toCGPoint: moveToPoint)
            } else {
                delegate!.beginRandomMovement()
            }
        }
    }

    func think(currentTime: TimeInterval) {
        if lifeState {
            // MARK: Decision Making
            if delegate!.currentHealth <= 100 {
                if currentState != .movingToFood || currentFoodTarget == nil {
                    currentState = .locatingFood
                }
            } else if delegate!.currentHealth > 250, delegate!.lifeTime >= 30 {
                if currentState != .movingToLove {
                    currentState = .locatingLove
                }
            } else if currentState != .randomMovement {
                delegate!.beginRandomMovement()
            }

            switch delegate!.currentHealth {
            case 0...100:
                if currentFoodTarget == nil {
                    currentState = .locatingFood
                }
            case 250...:
                currentState = .locatingLove
            default:
                delegate!.beginRandomMovement()
            }

            switch currentState {
            case .randomMovement:
                moveRandomly()
            case .locatingFood:
                locateFood()
            case .movingToFood:
                moveToFood()
            case .locatingLove:
                locateLove()
            case .movingToLove:
                moveToLove()
            case .dead:
                break
            case .nothing:
                break
            }
        }
    }
}
