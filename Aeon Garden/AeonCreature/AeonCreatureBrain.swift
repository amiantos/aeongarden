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
    func getFoodNodes() -> [AeonFood]
    func getEligibleMates() -> [AeonCreature]
    func getEligiblePlayMates() -> [SKNode]
    func getCurrentHealth() -> Float

    func setCurrentTarget(node: SKNode?)
    func getDistance(toNode node: SKNode) -> CGFloat
    func rate(mate: AeonCreature) -> CGFloat

    func die()

    func printThought(_ message: String, emoji: String?)
}

class AeonCreatureBrain: Updatable {
    weak var delegate: AeonCreatureBrainDelegate?
    var stateMachine: GKStateMachine?

    public var currentFeeling: Feeling = .bored
    public var currentState: State = State.living
    public var currentFoodTarget: AeonFood?
    public var currentLoveTarget: AeonCreature?
    public var currentPlayTarget: SKNode?
    private var lifeState: Bool = true {
        didSet {
            if !lifeState {
                stateMachine?.enter(DeadState.self)
            }
        }
    }

    public enum State: String {
        case living = "Newborn"
        case randomMovement = "Bored"
        case locatingFood = "Looking for Food"
        case locatingLove = "Looking for Love"
        case dead = "Dying"
    }

    internal var lastUpdateTime: TimeInterval = 0

    init() {
        let living = BirthState(forBrain: self)
        let seekingLove = SeekingLoveState(forBrain: self)
        let seekingFood = SeekingFoodState(forBrain: self)
        let wandering = WanderingState(forBrain: self)
        let dying = DeadState(forBrain: self)
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

    func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let deltaTime = currentTime - lastUpdateTime
        if deltaTime <= 1 {
            let currentHealth = delegate!.getCurrentHealth()
            if currentHealth >= 600 {
                currentFeeling = .horny
            } else if currentHealth <= 300 {
                currentFeeling = .hungry
            }
//          Maybe playtime will return in the future
//          } else if currentHealth <= 400, currentFeeling == .horny {
//              currentFeeling = .bored
//          }
            stateMachine?.update(deltaTime: deltaTime)
            lastUpdateTime = currentTime
        }
    }

    public func locateLove() {
        var creatureDifferenceArray = [(
            rating: CGFloat,
            node: AeonCreature
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
        var foodArray = [(interestedCreatures: Int, distance: CGFloat, node: AeonFood)]()
        let nodes = getFoodNodes()
        for child in nodes {
            let distance = getDistance(toNode: child)
            if child == currentFoodTarget {
                foodArray.append((child.interestedCreatures - 1, distance, child))
            } else {
                foodArray.append((child.interestedCreatures, distance, child))
            }
        }
        foodArray.sort(by: { $0.interestedCreatures < $1.interestedCreatures })
        let prefix = Int(foodArray.count / 2)
        foodArray = Array(foodArray.prefix(upTo: prefix))
        foodArray.sort(by: { $0.distance < $1.distance })
        if foodArray.count > 0 {
            if currentFoodTarget != foodArray[0].node {
                currentFoodTarget?.interestedCreatures -= 1
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
    func getCurrentHealth() -> Float {
        return delegate!.getCurrentHealth()
    }

    func die() {
        stateMachine?.enter(DeadState.self)
    }

    func getEligiblePlayMates() -> [SKNode] {
        return delegate!.getEligibleMates()
    }

    func rate(mate: AeonCreature) -> CGFloat {
        return delegate!.rate(mate: mate)
    }

    func getDistance(toNode node: SKNode) -> CGFloat {
        return delegate!.getDistance(toNode: node)
    }

    func getFoodNodes() -> [AeonFood] {
        return delegate!.getFoodNodes()
    }

    func getEligibleMates() -> [AeonCreature] {
        return delegate!.getEligibleMates()
    }

    func setCurrentTarget(node: SKNode?) {
        delegate?.setCurrentTarget(node: node)
    }

    func printThought(_ message: String, emoji: String?) {
        delegate!.printThought(message, emoji: emoji)
    }
}
