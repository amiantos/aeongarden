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
    case horny = "Lonely"
    case bored = "Bored"
    case dying = "Dead"
}

protocol AeonCreatureBrainDelegate: class {
    func getFoodNodes() -> [AeonFoodNode]
    func getEligibleMates() -> [AeonCreatureNode]
    func getEligiblePlayMates() -> [AeonBubbleNode]
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
    public weak var currentFoodTarget: AeonFoodNode?
    public weak var currentLoveTarget: AeonCreatureNode?
    public weak var currentPlayTarget: AeonBubbleNode?
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
        case locatingFood = "Hungry"
        case locatingLove = "Lonely"
        case dead = "Dead"
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
            dead,
        ])
    }

    // MARK: - Thought Process

    public func startThinking() {
        stateMachine?.enter(BirthState.self)
    }

    func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let deltaTime = currentTime - lastUpdateTime
        if deltaTime >= 1 {
            let currentHealth = getCurrentHealth()
            if currentHealth >= 300 {
                currentFeeling = .horny
            } else if currentHealth <= 100 {
                currentFeeling = .hungry
            } else if currentHealth <= 200,
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

        creatureDifferenceArray.sort(by: {
            let distance0 = $0.distance * 0.4
            let distance1 = $1.distance * 0.4
            let rating0 = $0.rating
            let rating1 = $1.rating
            return (rating0 + distance0) < (rating1 + distance1)

        })

        if creatureDifferenceArray.count > 0 {
            currentLoveTarget = creatureDifferenceArray[0].node
        }
        if let loveTarget = currentLoveTarget {
            setCurrentTarget(node: loveTarget)
        } else {
            locatePlayTarget()
        }
    }

    public func locateFood() {
        var foodArray = [(rating: CGFloat, node: AeonFoodNode)]()
        let nodes = getFoodNodes()
        for child in nodes {
            var rating: CGFloat = 0
            if child == currentFoodTarget {
                rating = getDistance(toNode: child) + (CGFloat(child.interestedParties) * 250) - 250.0
            } else {
                rating = getDistance(toNode: child) + (CGFloat(child.interestedParties) * 250)
            }
            foodArray.append((rating, child))
        }
        foodArray.sort(by: { $0.rating < $1.rating })
        if foodArray.count > 0 {
            if currentFoodTarget != foodArray[0].node {
                currentFoodTarget?.untargeted()
                currentFoodTarget = foodArray[0].node
                currentFoodTarget?.targeted()
                setCurrentTarget(node: currentFoodTarget!)
            }
        }
    }

    public func locatePlayTarget() {
        var ballArray = [(rating: Int, node: SKNode)]()
        let nodes = getEligiblePlayMates()
        for child in nodes {
            ballArray.append((child.interestedParties, child))
        }
        ballArray.sort(by: { $0.rating < $1.rating })
        if let playTarget = ballArray.first?.node as? AeonBubbleNode, playTarget != currentPlayTarget {
            currentPlayTarget?.untargeted()
            currentPlayTarget = playTarget
            currentPlayTarget?.targeted()
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

    func getEligiblePlayMates() -> [AeonBubbleNode] {
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
