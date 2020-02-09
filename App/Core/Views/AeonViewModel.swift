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
    var autosaveTimer: Timer?

    var lastUserActivityTimeout: TimeInterval = 10 // default should be 120?
    var idleTimer: Timer?
    var autoCameraRunning: Bool = false

    init(for view: AeonViewController) {
        self.view = view

        autosaveTimer = Timer.scheduledTimer(
            timeInterval: 10,
            target: self,
            selector: #selector(autosave),
            userInfo: nil,
            repeats: true
        )

        activityOccurred()
    }

    @objc private func autosave() {
        guard let scene = scene else { return }
        Log.info("Running auto-save...")
        DispatchQueue.main.async {
            self.saveTank(scene)
        }
    }

    func activityOccurred() {
        Log.info("User activity occurred.")

        if let idleTimer = idleTimer {
            idleTimer.invalidate()
        }

        idleTimer = Timer.scheduledTimer(timeInterval: lastUserActivityTimeout, target: self, selector: #selector(startAutoCamera), userInfo: nil, repeats: false)

        if autoCameraRunning {
            stopAutoCamera()
        }
    }

    @objc private func startAutoCamera() {
        scene?.startAutoCamera()
        view?.hideAllMenusIfNeeded()
        autoCameraRunning = true
    }

    private func stopAutoCamera() {
        scene?.stopAutoCamera()
        autoCameraRunning = false
    }

    private func createScene(size: CGSize, device: DeviceType) -> AeonTankScene {
        let newScene = AeonTankScene(size: size)
        newScene.tankSettings = getTankSettings(for: device)
        newScene.interfaceDelegate = self
        newScene.scaleMode = .aspectFill
        return newScene
    }

    func createNewTank(size: CGSize, device: DeviceType) -> AeonTankScene {
        let newScene = createScene(size: size, device: device)
        CoreDataStore.standard.getCreatures { creatures in
            newScene.loadCreaturesIntoScene(creatures)
            newScene.createInitialCreatures()
            newScene.createInitialBubbles()
        }
        scene = newScene
        return newScene
    }

    func loadTank(size: CGSize, device: DeviceType, completion: @escaping (AeonTankScene) -> Void) {
        Tank.getAll { tanks in
            Log.info("Number of tanks in storage: \(tanks.count)")
            if let tank = tanks.last {
                let newScene = self.createScene(size: size, device: device)
                tank.restore(to: newScene)
                self.scene = newScene
                completion(newScene)
            } else {
                completion(self.createNewTank(size: size, device: device))
            }
        }
    }

    func saveTank(_ scene: AeonTankScene) {
        let tankStruct = Tank.from(scene)
        tankStruct.save()
    }

    func saveCreature(_ creature: AeonCreatureNode) {
        let creatureStruct = Creature.from(creature)
        creatureStruct.save()
    }

    func deleteCreature(_ creature: AeonCreatureNode) {
        let creatureStruct = Creature.from(creature)
        creatureStruct.delete()
    }

    func renameCreature(_ creature: AeonCreatureNode, firstName: String, lastName: String) {
        creature.firstName = firstName
        creature.lastName = lastName
        creature.fullName = "\(firstName) \(lastName)"
        if creature.isFavorite {
            saveCreature(creature)
        }
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
                creatureBirthSuccessRate: 0.10,
                backgroundParticleBirthrate: 30,
                backgroundParticleLifetime: 20
            )
        case .tv:
            tankSettings = TankSettings(
                foodMaxAmount: 25,
                foodHealthRestorationBaseValue: 120,
                foodSpawnRate: 2,
                creatureInitialAmount: 30,
                creatureMinimumAmount: 15,
                creatureSpawnRate: 5,
                creatureBirthSuccessRate: 0.10,
                backgroundParticleBirthrate: 60,
                backgroundParticleLifetime: 50
            )
        default:
            tankSettings = TankSettings(
                foodMaxAmount: 15,
                foodHealthRestorationBaseValue: 120,
                foodSpawnRate: 2,
                creatureInitialAmount: 20,
                creatureMinimumAmount: 10,
                creatureSpawnRate: 5,
                creatureBirthSuccessRate: 0.10,
                backgroundParticleBirthrate: 40,
                backgroundParticleLifetime: 30
            )
        }
        return tankSettings!
    }
}

extension AeonViewModel: AeonTankInterfaceDelegate {
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
