//
//  AeonCreatureStates.swift
//  Aeon Garden
//
//  Created by Brad Root on 3/8/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation
import GameKit

class WanderingState: GKState {
    weak var brain: AeonCreatureBrain?

    init(forBrain brain: AeonCreatureBrain) {
        self.brain = brain
    }

    override func didEnter(from _: GKState?) {
        brain?.printThought("I'm bored.", emoji: nil)
        brain?.currentState = .randomMovement
    }

    override func update(deltaTime _: TimeInterval) {
        if let brain = brain {
            switch brain.currentFeeling {
            case .hungry:
                stateMachine?.enter(SeekingFoodState.self)
            case .horny:
                stateMachine?.enter(SeekingLoveState.self)
            case .bored:
                brain.analyzePlayTarget()
                if brain.currentPlayTarget == nil {
                    brain.locatePlayTarget()
                }
            case .dying:
                stateMachine?.enter(DyingState.self)
            }
        }
    }
}

// MARK: - Hunger

class SeekingFoodState: GKState {
    weak var brain: AeonCreatureBrain?

    init(forBrain brain: AeonCreatureBrain) {
        self.brain = brain
    }

    override func isValidNextState(_: AnyClass) -> Bool {
        return true
    }

    override func didEnter(from _: GKState?) {
        brain?.printThought("Looking for food.", emoji: "👀")
        brain?.currentState = .locatingFood
    }

    override func update(deltaTime _: TimeInterval) {
        if let brain = brain {
            switch brain.currentFeeling {
            case .hungry:
                brain.locateFood()
                if brain.currentFoodTarget != nil {
                    stateMachine?.enter(ApproachingFoodState.self)
                }
            case .horny:
                stateMachine?.enter(SeekingLoveState.self)
            case .bored:
                stateMachine?.enter(WanderingState.self)
            case .dying:
                stateMachine?.enter(DyingState.self)
            }
        }
    }
}

class ApproachingFoodState: GKState {
    weak var brain: AeonCreatureBrain?

    init(forBrain brain: AeonCreatureBrain) {
        self.brain = brain
    }

    override func didEnter(from _: GKState?) {
        brain?.printThought("Approaching food.", emoji: "😋")
        brain?.currentState = .movingToFood
    }

    override func update(deltaTime _: TimeInterval) {
        if let brain = brain {
            switch brain.currentFeeling {
            case .hungry:
                brain.locateFood()
                if brain.currentFoodTarget == nil {
                    stateMachine?.enter(SeekingFoodState.self)
                }
            case .horny:
                stateMachine?.enter(SeekingLoveState.self)
            case .bored:
                stateMachine?.enter(WanderingState.self)
            case .dying:
                stateMachine?.enter(DyingState.self)
            }
        }
    }

    override func willExit(to _: GKState) {
        brain?.currentFoodTarget = nil
    }
}

// MARK: - Romance

class SeekingLoveState: GKState {
    weak var brain: AeonCreatureBrain?

    init(forBrain brain: AeonCreatureBrain) {
        self.brain = brain
    }

    override func didEnter(from _: GKState?) {
        brain?.printThought("Feeling good, gonna look for love!", emoji: "👀")
        brain?.currentState = .locatingLove
    }

    override func update(deltaTime _: TimeInterval) {
        if let brain = brain {
            switch brain.currentFeeling {
            case .hungry:
                stateMachine?.enter(SeekingFoodState.self)
            case .horny:
                brain.locateLove()
                if brain.currentLoveTarget != nil {
                    stateMachine?.enter(ApproachingLoveState.self)
                }
            case .bored:
                stateMachine?.enter(WanderingState.self)
            case .dying:
                stateMachine?.enter(DyingState.self)
            }
        }
    }
}

class ApproachingLoveState: GKState {
    weak var brain: AeonCreatureBrain?

    init(forBrain brain: AeonCreatureBrain) {
        self.brain = brain
    }

    override func didEnter(from _: GKState?) {
        brain?.printThought("Oh, \(brain!.currentLoveTarget!.fullName) caught my eye.", emoji: "😍")
        brain?.currentState = .movingToLove
    }

    override func update(deltaTime _: TimeInterval) {
        if let brain = brain {
            switch brain.currentFeeling {
            case .hungry:
                stateMachine?.enter(SeekingFoodState.self)
            case .horny:
                if brain.currentLoveTarget == nil {
                    stateMachine?.enter(SeekingLoveState.self)
                }
            case .bored:
                stateMachine?.enter(WanderingState.self)
            case .dying:
                stateMachine?.enter(DyingState.self)
            }
        }
    }

    override func willExit(to _: GKState) {
        brain?.currentLoveTarget = nil
    }
}

class DyingState: GKState {
    weak var brain: AeonCreatureBrain?

    init(forBrain brain: AeonCreatureBrain) {
        self.brain = brain
    }

    override func didEnter(from _: GKState?) {
        brain?.printThought("Oh no! I'm dying.", emoji: "☠️")
        brain?.currentState = .dead
    }
}
