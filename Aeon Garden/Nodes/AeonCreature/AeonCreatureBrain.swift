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
    func getFoodNodes() -> [AeonFoodNode]
    func getEligibleMates() -> [AeonCreatureNode]
    func getEligiblePlayMates() -> [SKNode]

    func setCurrentTarget(node: SKNode?)
    func getCurrentFeeling() -> Feeling
    func getDistance(toNode node: SKNode) -> CGFloat
    func rate(mate: AeonCreatureNode) -> CGFloat

    func printThought(_ message: String, emoji: String?)
}

class AeonCreatureBrain {
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
        case locatingFood = "Looking for Food"
        case locatingLove = "Looking for Love"
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

    // MARK: - Thought Process

    public func startThinking() {
        stateMachine?.enter(BirthState.self)
    }

    func think(deltaTime: TimeInterval) {
        currentFeeling = delegate!.getCurrentFeeling()
        stateMachine?.update(deltaTime: deltaTime)
    }

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
        if currentFoodTarget == nil {
            var foodArray = [(interestedCreatures: Int, distance: CGFloat, node: AeonFoodNode)]()
            let nodes = getFoodNodes()
            for child in nodes {
                let distance = getDistance(toNode: child)
                foodArray.append((child.interestedCreatures, distance, child))
            }
            foodArray.sort(by: { $0.interestedCreatures < $1.interestedCreatures })
            let prefix = Int(foodArray.count / 2)
            foodArray = Array(foodArray.prefix(upTo: prefix))
            foodArray.sort(by: { $0.distance < $1.distance })
            if foodArray.count > 0 {
                currentFoodTarget = foodArray[0].node
                currentFoodTarget?.interestedCreatures += 1
                setCurrentTarget(node: currentFoodTarget!)
            }
        }
    }

    public func analyzePlayTarget() {
        if let playTarget = currentPlayTarget, getDistance(toNode: playTarget) < 100 {
            currentPlayTarget = nil
        }
    }

    public func locatePlayTarget() {
        var ratedNodeArray: [SKNode] = []
        let nodes = getEligiblePlayMates()
        for child in nodes {
            let distance = getDistance(toNode: child)
            if distance > 100 {
                ratedNodeArray.append(child)
            }
        }
        if let playTarget = ratedNodeArray.randomElement() {
            currentPlayTarget = playTarget
            setCurrentTarget(node: playTarget)
        }
    }
}

extension AeonCreatureBrain: AeonCreatureBrainDelegate {
    func getEligiblePlayMates() -> [SKNode] {
        return delegate!.getEligibleMates()
    }

    func rate(mate: AeonCreatureNode) -> CGFloat {
        return delegate!.rate(mate: mate)
    }

    func getDistance(toNode node: SKNode) -> CGFloat {
        return delegate!.getDistance(toNode: node)
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
}
