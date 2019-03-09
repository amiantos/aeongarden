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
    var fullName: String { get set }
    var lastName: String { get set }
    var parentNames: [String] { get set }

    func beginRandomMovement()
    func distance(point: CGPoint) -> CGFloat

    func getNodes(atPosition position: CGPoint) -> [SKNode]
    func getNodes() -> [SKNode]
    func getNode(byName name: String) -> SKNode?

    func move(toCGPoint: CGPoint)
}

class AeonCreatureBrain {
    weak var delegate: AeonCreatureBrainDelegate?
    var stateMachine: GKStateMachine?

    public var currentState: State = State.nothing
    public var currentFoodTarget: AeonFoodNode?
    public var currentLoveTarget: AeonCreatureNode?
    public var currentMoveTarget: CGPoint?
    public var lifeState: Bool = true {
        didSet {
            if !self.lifeState {
                stateMachine?.enter(DyingState.self)
            }
        }
    }

    public enum State: String {
        case nothing = "Thinking"
        case randomMovement = "Wandering"
        case locatingFood = "Locating Food"
        case movingToFood = "Approaching Food"
        case locatingLove = "Looking for Love"
        case movingToLove = "Chasing Love"
        case dead = "Dying"
    }

    init() {
        let seekingLove = SeekingLoveState(forBrain: self)
        let approachingLove = ApproachingLoveState(forBrain: self)
        let seekingFood = SeekingFoodState(forBrain: self)
        let approachingFood = ApproachingFoodState(forBrain: self)
        let wandering = WanderingState(forBrain: self)
        let dying = DyingState(forBrain: self)
        self.stateMachine = GKStateMachine(states: [
            seekingLove,
            approachingLove,
            seekingFood,
            approachingFood,
            wandering,
            dying
        ])
    }

    func printThought(_ message: String, emoji: String?) {
        NSLog("\(emoji ?? "💭") \(delegate!.fullName): \(message)")
    }

    // MARK: - Thought Process

    public func locateLove() {
        var creatureDifferenceArray = [(speed: CGFloat, distance: CGFloat, node: AeonCreatureNode)]()
        let nodes = delegate!.getNodes()
        for case let child as AeonCreatureNode in nodes where
            child != delegate as? AeonCreatureNode
            && delegate!.parentNames.contains(child.lastName) == false
            && child.parentNames.contains(delegate!.lastName) == false {
            let distanceComputed = delegate!.distance(point: child.position)
            creatureDifferenceArray.append((child.movementSpeed, distanceComputed, child))
        }

        creatureDifferenceArray.sort(by: { $0.distance > $1.distance })

        if creatureDifferenceArray.count > 0 {
            currentLoveTarget = creatureDifferenceArray[0].node
        }
    }

    public func moveToLove() {
        if let loveTarget = currentLoveTarget {
            if let node = delegate!.getNode(byName: loveTarget.fullName) {
                delegate!.move(toCGPoint: node.position)
            } else {
                currentLoveTarget = nil
            }
        }
    }

    public func locateFood() {
        var foodDistanceArray = [(distance: CGFloat, node: AeonFoodNode)]()
        let nodes = delegate!.getNodes()
        for case let child as AeonFoodNode in nodes {
            let distanceComputed = delegate!.distance(point: child.position)
            foodDistanceArray.append((distanceComputed, child))
        }
        foodDistanceArray.sort(by: { $0.distance < $1.distance })
        if foodDistanceArray.count > 0 {
            currentFoodTarget = foodDistanceArray[0].node
        }
    }

    public func moveToFood() {
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
            }
        }
    }

    public func moveRandomly() {
        var nodeFound = 0
        // Check if self is not already at point...
        if let moveTarget = self.currentMoveTarget {
            let nodes = delegate!.getNodes(atPosition: moveTarget)
            for node in nodes where node == delegate as? AeonCreatureNode {
                nodeFound = 1
            }
            if nodeFound == 0 {
                delegate!.move(toCGPoint: moveTarget)
            } else {
                delegate!.beginRandomMovement()
            }
        } else {
            delegate!.beginRandomMovement()
        }
    }

    func startThinking() {
        stateMachine?.enter(WanderingState.self)
    }

    func think(deltaTime: TimeInterval) {
        stateMachine?.update(deltaTime: deltaTime)
    }
}
