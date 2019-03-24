//
//  AeonCreatureBrain.swift
//  Aeon Garden
//
//  Created by Brad Root on 3/7/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import GameplayKit

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
    func getCurrentHealth() -> Float

    func setCurrentTarget(node: SKNode?)
    func getDistance(toNode node: SKNode) -> CGFloat
    func rateMate(_ mate: AeonCreatureNode) -> CGFloat

    func die()
    func mated()
    func fed()

    func printThought(_ message: String, emoji: String?)
}

class AeonCreatureBrain: Updatable {
    weak var delegate: AeonCreatureBrainDelegate?
    var stateMachine: GKStateMachine?

    public var currentFeeling: Feeling = .bored
    public var currentState: State = State.living
    public var currentFoodTarget: AeonFoodNode?
    public var currentLoveTarget: AeonCreatureNode?
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
        let dead = DeadState(forBrain: self)
        stateMachine = GKStateMachine(states: [
            living,
            seekingLove,
            seekingFood,
            wandering,
            dead
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
            let currentHealth = getCurrentHealth()
            if currentHealth >= 400 {
                currentFeeling = .horny
            } else if currentHealth <= 200 {
                currentFeeling = .hungry
            } else if currentHealth <= 300,
                currentFeeling == .horny {
                currentFeeling = .bored
            }
            stateMachine?.update(deltaTime: deltaTime)
            lastUpdateTime = currentTime
        }
    }

    public func locateLove() {
        var creatureDifferenceArray = [(
            rating: CGFloat,
            distance: CGFloat,
            node: AeonCreatureNode
        )]()
        let nodes = getEligibleMates()
        for child in nodes {
            let mateRating = rateMate(child)
            let distance = getDistance(toNode: child)
            creatureDifferenceArray.append((mateRating, distance, child))
        }

        creatureDifferenceArray.sort(by: { $0.distance < $1.distance })
        let prefix = creatureDifferenceArray.count < 5 ? creatureDifferenceArray.count : 5
        creatureDifferenceArray = Array(creatureDifferenceArray.prefix(upTo: prefix))
        creatureDifferenceArray.sort(by: { $0.rating < $1.rating })

        if creatureDifferenceArray.count > 0 {
            if creatureDifferenceArray[0].node != currentLoveTarget {
                currentLoveTarget = creatureDifferenceArray[0].node
                setCurrentTarget(node: currentLoveTarget!)
            }
        }
    }

    public func locateFood() {
        var foodArray = [(rating: CGFloat, node: AeonFoodNode)]()
        let nodes = getFoodNodes()
        for child in nodes {
            var rating: CGFloat = 0
            if child == currentFoodTarget {
                rating = getDistance(toNode: child) + (CGFloat(child.interestedCreatures) * 250) - 250.0
            } else {
                rating = getDistance(toNode: child) + (CGFloat(child.interestedCreatures) * 250)
            }
            foodArray.append((rating, child))
        }
        foodArray.sort(by: { $0.rating < $1.rating })
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
//        if let playTarget = currentPlayTarget, getDistance(toNode: playTarget) < 100 {
//            currentPlayTarget = nil
//        }
    }

    public func locatePlayTarget() {
        var ballArray = [(rating: CGFloat, node: SKNode)]()
        let nodes = getEligiblePlayMates()
        for child in nodes {
            let distance = getDistance(toNode: child)
            ballArray.append((distance, child))
        }
        ballArray.sort(by: { $0.rating < $1.rating })
        if let playTarget = ballArray.first?.node {
            currentPlayTarget = playTarget
            setCurrentTarget(node: currentPlayTarget)
        }
    }
}

extension AeonCreatureBrain: AeonCreatureBrainDelegate {
    func mated() {
        currentLoveTarget = nil
        stateMachine?.enter(WanderingState.self)
    }

    func fed() {
        currentFoodTarget = nil
    }

    func die() {
        stateMachine?.enter(DeadState.self)
    }

    func getCurrentHealth() -> Float {
        return delegate!.getCurrentHealth()
    }

    func getEligiblePlayMates() -> [SKNode] {
        return delegate!.getEligiblePlayMates()
    }

    func rateMate(_ mate: AeonCreatureNode) -> CGFloat {
        return delegate!.rateMate(mate)
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

    func printThought(_ message: String, emoji: String?) {
        delegate!.printThought(message, emoji: emoji)
    }
}
