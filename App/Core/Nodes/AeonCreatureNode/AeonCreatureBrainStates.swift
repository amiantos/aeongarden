//
//  AeonCreatureBrainStates.swift
//  Aeon Garden
//
//  Created by Brad Root on 3/8/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import GameKit

class BirthState: GKState {
    weak var brain: AeonCreatureBrain?

    init(forBrain brain: AeonCreatureBrain) {
        self.brain = brain
    }

    override func didEnter(from _: GKState?) {
        brain?.currentState = .living
    }

    override func update(deltaTime _: TimeInterval) {
        if let brain = brain {
            switch brain.currentFeeling {
            case .hungry:
                stateMachine?.enter(SeekingFoodState.self)
            case .horny:
                stateMachine?.enter(SeekingLoveState.self)
            case .bored:
                stateMachine?.enter(WanderingState.self)
            case .dying:
                stateMachine?.enter(DeadState.self)
            }
        }
    }
}

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
                brain.locatePlayTarget()
            case .dying:
                stateMachine?.enter(DeadState.self)
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
        brain?.printThought("Looking for food.", emoji: "😋")
        brain?.currentState = .locatingFood
    }

    override func update(deltaTime _: TimeInterval) {
        if let brain = brain {
            switch brain.currentFeeling {
            case .hungry:
                brain.locateFood()
            case .horny:
                stateMachine?.enter(SeekingLoveState.self)
            case .bored:
                stateMachine?.enter(WanderingState.self)
            case .dying:
                stateMachine?.enter(DeadState.self)
            }
        }
    }
}

// MARK: - Romance

class SeekingLoveState: GKState {
    weak var brain: AeonCreatureBrain?

    init(forBrain brain: AeonCreatureBrain) {
        self.brain = brain
    }

    override func didEnter(from _: GKState?) {
        brain?.printThought("Looking for love.", emoji: "😍")
        brain?.currentState = .locatingLove
    }

    override func update(deltaTime _: TimeInterval) {
        if let brain = brain {
            switch brain.currentFeeling {
            case .hungry:
                stateMachine?.enter(SeekingFoodState.self)
            case .horny:
                brain.locateLove()
            case .bored:
                stateMachine?.enter(WanderingState.self)
            case .dying:
                stateMachine?.enter(DeadState.self)
            }
        }
    }
}

class DeadState: GKState {
    weak var brain: AeonCreatureBrain?

    init(forBrain brain: AeonCreatureBrain) {
        self.brain = brain
    }

    override func didEnter(from _: GKState?) {
        brain?.printThought("Oh no! I'm dying.", emoji: "☠️")
        brain?.currentState = .dead
    }

    override func isValidNextState(_: AnyClass) -> Bool {
        return false
    }
}
