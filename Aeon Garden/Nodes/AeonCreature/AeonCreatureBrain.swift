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

enum Feeling: String {
    case hungry = "Hungry"
    case horny = "Horny"
    case bored = "Bored"
    case dying = "Dying"
}

protocol AeonCreatureBrainDelegate: class {
    func getNodes(atPosition position: CGPoint) -> [SKNode]
    func getNodes() -> [SKNode]
    func getNode(byName name: String) -> SKNode?

    func getFoodNodes() -> [AeonFoodNode]
    func getEligibleMates() -> [AeonCreatureNode]

    func setCurrentTarget(node: SKNode?)
    func getCurrentFeeling() -> Feeling
    func getDistance(toNode node: SKNode) -> CGFloat
    func rate(mate: AeonCreatureNode) -> CGFloat

    func printThought(_ message: String, emoji: String?)
}

class AeonCreatureBrain: AeonCreatureBrainDelegate {
    func rate(mate: AeonCreatureNode) -> CGFloat {
        return delegate!.rate(mate: mate)
    }

    func getDistance(toNode node: SKNode) -> CGFloat {
        return delegate!.getDistance(toNode: node)
    }

    func getNodes(atPosition position: CGPoint) -> [SKNode] {
        return delegate!.getNodes(atPosition: position)
    }

    func getNodes() -> [SKNode] {
        return delegate!.getNodes()
    }

    func getNode(byName name: String) -> SKNode? {
        return delegate!.getNode(byName: name)
    }

    func getFoodNodes() -> [AeonFoodNode] {
        return delegate!.getFoodNodes()
    }

    func getEligibleMates() -> [AeonCreatureNode] {
        return delegate!.getEligibleMates()
    }

    func setCurrentTarget(node: SKNode?) {
        delegate?.setCurrentTarget(node: node)
    }

    func getCurrentFeeling() -> Feeling {
        return delegate!.getCurrentFeeling()
    }

    func printThought(_ message: String, emoji: String?) {
        delegate!.printThought(message, emoji: emoji)
    }

    weak var delegate: AeonCreatureBrainDelegate?
    var stateMachine: GKStateMachine?

    public var currentState: State = State.living
    public var currentFoodTarget: AeonFoodNode?
    public var currentLoveTarget: AeonCreatureNode?
    public var currentPlayTarget: SKNode?
    public var lifeState: Bool = true {
        didSet {
            if !lifeState {
                stateMachine?.enter(DyingState.self)
            }
        }
    }

    public var currentFeeling: Feeling = .bored

    public enum State: String {
        case living = "Newborn"
        case randomMovement = "Bored"
        case locatingFood = "Locating Food"
        case movingToFood = "Approaching Food"
        case locatingLove = "Looking for Love"
        case movingToLove = "Chasing Love"
        case dead = "Dying"
    }

    init() {
        let living = BirthState(forBrain: self)
        let seekingLove = SeekingLoveState(forBrain: self)
        let seekingFood = SeekingFoodState(forBrain: self)
        let wandering = WanderingState(forBrain: self)
        let dying = DyingState(forBrain: self)
        stateMachine = GKStateMachine(states: [
            living,
            seekingLove,
            seekingFood,
            wandering,
            dying
        ])
    }

    public func startThinking() {
        stateMachine?.enter(BirthState.self)
    }

    // MARK: - Thought Process

    public func locateLove() {
        var creatureDifferenceArray = [(
            rating: CGFloat,
            node: AeonCreatureNode
        )]()
        let nodes = getEligibleMates()
        for child in nodes {
            let mateRating = rate(mate: child)
            creatureDifferenceArray.append((mateRating, child))
        }

        creatureDifferenceArray.sort(by: { $0.rating < $1.rating })

        if creatureDifferenceArray.count > 0 {
            currentLoveTarget = creatureDifferenceArray[0].node
            setCurrentTarget(node: currentLoveTarget!)
        }
    }

    public func locateFood() {
        var foodDistanceArray = [(rating: CGFloat, node: AeonFoodNode)]()
        let nodes = getFoodNodes()
        for child in nodes {
            let foodRating = getDistance(toNode: child)
            foodDistanceArray.append((foodRating, child))
        }
        foodDistanceArray.sort(by: { $0.rating < $1.rating })
        if foodDistanceArray.count > 0 {
            currentFoodTarget = foodDistanceArray[0].node
            setCurrentTarget(node: currentFoodTarget!)
        }
    }

    public func analyzePlayTarget() {
        if let playTarget = currentPlayTarget, getDistance(toNode: playTarget) < 100 {
            currentPlayTarget = nil
        }
    }

    public func locatePlayTarget() {
        var ratedNodeArray: [SKNode] = []
        let nodes = getNodes()
        for child in nodes {
            let distance = getDistance(toNode: child)
            if distance > 700 {
                ratedNodeArray.append(child)
            }
        }
        if let playTarget = ratedNodeArray.randomElement() {
            currentPlayTarget = playTarget
            setCurrentTarget(node: playTarget)
        }
    }

    func think(deltaTime: TimeInterval) {
        currentFeeling = delegate!.getCurrentFeeling()
        stateMachine?.update(deltaTime: deltaTime)
    }
}
