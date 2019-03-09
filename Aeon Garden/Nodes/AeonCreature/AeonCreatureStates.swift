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

    override func didEnter(from previousState: GKState?) {
        brain?.printThought("I guess I'll wander around.", emoji: "🙃")
        brain?.currentState = .randomMovement
    }

    override func update(deltaTime seconds: TimeInterval) {
        brain?.moveRandomly()
        if (brain?.delegate?.currentHealth)! <= Float(100) {
            stateMachine?.enter(SeekingFoodState.self)
        }
    }
}

// MARK: - Hunger

class SeekingFoodState: GKState {
    weak var brain: AeonCreatureBrain?

    init(forBrain brain: AeonCreatureBrain) {
        self.brain = brain
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }

    override func didEnter(from previousState: GKState?) {
        brain?.printThought("Looking for food.", emoji: "🔎")
        brain?.currentState = .locatingFood
    }

    override func update(deltaTime seconds: TimeInterval) {
        if brain?.currentFoodTarget != nil {
            stateMachine?.enter(ApproachingFoodState.self)
        } else {
            brain?.locateFood()
        }
    }
}

class ApproachingFoodState: GKState {
    weak var brain: AeonCreatureBrain?

    init(forBrain brain: AeonCreatureBrain) {
        self.brain = brain
    }

    override func didEnter(from previousState: GKState?) {
        brain?.printThought("Approaching food.", emoji: "😋")
        brain?.currentState = .movingToFood
    }

    override func update(deltaTime seconds: TimeInterval) {
        if (brain?.delegate?.currentHealth)! >= Float(250) {
            stateMachine?.enter(SeekingLoveState.self)
        } else if brain?.currentFoodTarget == nil {
            stateMachine?.enter(SeekingFoodState.self)
        } else {
            brain?.moveToFood()
        }
    }

    override func willExit(to nextState: GKState) {
        brain?.currentFoodTarget = nil
    }
}

// MARK: - Romance

class SeekingLoveState: GKState {
    weak var brain: AeonCreatureBrain?

    init(forBrain brain: AeonCreatureBrain) {
        self.brain = brain
    }

    override func didEnter(from previousState: GKState?) {
        brain?.printThought("Feeling good, gonna look for love!", emoji: "🥰")
        brain?.currentState = .locatingLove
    }

    override func update(deltaTime seconds: TimeInterval) {
        if (brain?.delegate?.currentHealth)! <= Float(100) {
            stateMachine?.enter(SeekingFoodState.self)
        } else if (brain?.delegate?.currentHealth)! <= Float(250) {
            stateMachine?.enter(WanderingState.self)
        } else if brain?.currentLoveTarget != nil {
            stateMachine?.enter(ApproachingLoveState.self)
        } else {
            brain?.locateLove()
        }
    }
}

class ApproachingLoveState: GKState {
    weak var brain: AeonCreatureBrain?

    init(forBrain brain: AeonCreatureBrain) {
        self.brain = brain
    }

    override func didEnter(from previousState: GKState?) {
        brain?.printThought("Oh, \(brain!.currentLoveTarget!.fullName) caught my eye.", emoji: "😍")
        brain?.currentState = .movingToLove
    }

    override func update(deltaTime seconds: TimeInterval) {
        if (brain?.delegate?.currentHealth)! <= Float(100) {
            stateMachine?.enter(SeekingFoodState.self)
        } else if (brain?.delegate?.currentHealth)! <= Float(200) {
            stateMachine?.enter(WanderingState.self)
        } else if brain?.currentLoveTarget == nil {
            stateMachine?.enter(SeekingLoveState.self)
        } else {
            brain?.moveToLove()
        }
    }

    override func willExit(to nextState: GKState) {
        brain?.currentLoveTarget = nil
    }

}

class DyingState: GKState {
    weak var brain: AeonCreatureBrain?

    init(forBrain brain: AeonCreatureBrain) {
        self.brain = brain
    }

    override func didEnter(from previousState: GKState?) {
        brain?.currentState = .dead
    }

}
