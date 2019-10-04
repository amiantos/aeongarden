//
//  AeonViewModel.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/4/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation
import UIKit

enum DeviceType {
    case ipad
    case iphone
    case tv
}

class AeonViewModel {

    weak var view: AeonViewController?
    weak var scene: AeonTankScene?

    var temporarySavedTank: Tank?

    init(for view: AeonViewController) {
        self.view = view
    }

    private func createScene(size: CGSize, device: DeviceType) -> AeonTankScene {
        let newScene = AeonTankScene(size: size)
        newScene.tankSettings = getTankSettings(for: device)
        newScene.tankDelegate = self
        newScene.scaleMode = .aspectFill
        return newScene
    }

    func createNewTank(size: CGSize, device: DeviceType) -> AeonTankScene {
        let newScene = createScene(size: size, device: device)
        newScene.createInitialCreatures()
        newScene.createInitialBubbles()
        scene = newScene
        return newScene
    }

    func loadTank(size: CGSize, device: DeviceType) -> AeonTankScene {
        guard let tankStruct = temporarySavedTank else {
            return createNewTank(size: size, device: device)
        }
        let newScene = createScene(size: size, device: device)
        tankStruct.restore(to: newScene)
        scene = newScene
        return newScene
    }

    func saveTank(_ scene: AeonTankScene) {
        let tankStruct = Tank.from(scene)
        temporarySavedTank = tankStruct
    }

    func getTankSettings(for device: DeviceType) -> TankSettings {
        var tankSettings: TankSettings?
        switch device {
        case .iphone:
            tankSettings = TankSettings(
                foodMaxAmount: 10,
                foodHealthRestorationBaseValue: 120,
                foodSpawnRate: 2,
                creatureInitialAmount: 10,
                creatureMinimumAmount: 5,
                creatureSpawnRate: 5,
                creatureBirthSuccessRate: 0.17,
                backgroundColor: .aeonDarkBlue,
                backgroundParticleBirthrate: 30,
                backgroundParticleLifetime: 20
            )
        case .tv:
            tankSettings = TankSettings(
                foodMaxAmount: 30,
                foodHealthRestorationBaseValue: 120,
                foodSpawnRate: 2,
                creatureInitialAmount: 30,
                creatureMinimumAmount: 5,
                creatureSpawnRate: 5,
                creatureBirthSuccessRate: 0.17,
                backgroundColor: .aeonDarkBlue,
                backgroundParticleBirthrate: 60,
                backgroundParticleLifetime: 50
            )
        default:
            tankSettings = TankSettings(
                foodMaxAmount: 20,
                foodHealthRestorationBaseValue: 120,
                foodSpawnRate: 2,
                creatureInitialAmount: 20,
                creatureMinimumAmount: 5,
                creatureSpawnRate: 5,
                creatureBirthSuccessRate: 0.17,
                backgroundColor: .aeonDarkBlue,
                backgroundParticleBirthrate: 40,
                backgroundParticleLifetime: 30
            )
        }
        return tankSettings!
    }

}

extension AeonViewModel: AeonTankUIDelegate {
    func updatePopulation(_ population: Int) {
        view?.updatePopulation(population)
    }

    func updateFood(_ food: Int) {
        view?.updateFood(food)
    }

    func updateBirths(_ births: Int) {
        view?.updateBirths(births)
    }

    func updateDeaths(_ deaths: Int) {
        view?.updateDeaths(deaths)
    }

    func updateClock(_ clock: String) {
        view?.updateClock(clock)
    }

    func updateSelectedCreatureDetails(_ creature: AeonCreatureNode) {
        view?.updateSelectedCreatureDetails(creature)
    }

    func creatureDeselected() {
        view?.creatureDeselected()
    }

    func creatureSelected(_ creature: AeonCreatureNode) {
        view?.creatureSelected(creature)
    }
}
