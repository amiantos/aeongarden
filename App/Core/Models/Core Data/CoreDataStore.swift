//
//  CoreDataStore.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/4/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import CoreData
import Foundation

class CoreDataStore {
    static let standard: CoreDataStore = CoreDataStore()

    var mainManagedObjectContext: NSManagedObjectContext
    var persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = {
            let container = NSPersistentContainer(name: "AeonGarden")
            container.loadPersistentStores(completionHandler: { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
        mainManagedObjectContext = persistentContainer.viewContext
    }

    deinit {
        self.saveContext()
    }

    func saveContext() {
        if mainManagedObjectContext.hasChanges {
            do {
                try mainManagedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it
                // may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension CoreDataStore: DataStoreProtocol {

    // MARK: - Creature Favorites
    func saveCreature(_ creature: Creature) {
        fatalError()
    }

    func deleteCreature(_ creature: Creature) {
        fatalError()
    }

    func getCreatures(completion: @escaping ([Creature]) -> Void) {
        fatalError()
    }

    // MARK: - Tanks

    func getTanks(completion: @escaping ([Tank]) -> Void) {
        mainManagedObjectContext.perform {
            do {
                let fetchRequest: NSFetchRequest<ManagedTank> = ManagedTank.fetchRequest()
                let managedTanks = try self.mainManagedObjectContext.fetch(fetchRequest) as [ManagedTank]
                var tanks: [Tank] = []
                for managedTank in managedTanks {
                    tanks.append(managedTank.toStruct())
                }
                completion(tanks)
            } catch {
                completion([])
            }
        }
    }

    func saveTank(_ tank: Tank) {
        mainManagedObjectContext.perform {
            do {
                // Check for tank in storage by UUID and delete it
                let fetchRequest: NSFetchRequest<ManagedTank> = ManagedTank.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "uuid == %@", tank.uuid.uuidString)
                if let tank = try? self.mainManagedObjectContext.fetch(fetchRequest).first {
                    self.mainManagedObjectContext.delete(tank)
                }

                let managedTank = ManagedTank(context: self.mainManagedObjectContext)

                managedTank.timestamp = Date()
                managedTank.birthCount = Int16(tank.birthCount)
                managedTank.deathCount = Int16(tank.deathCount)
                managedTank.tankTime = tank.tankTime
                managedTank.uuid = tank.uuid

                var managedCreatures: [ManagedTankCreature] = []
                for creature in tank.creatures {
                    let managedTankCreature = ManagedTankCreature(context: self.mainManagedObjectContext)
                    managedTankCreature.uuid = creature.uuid
                    managedTankCreature.firstName = creature.firstName
                    managedTankCreature.lastName = creature.lastName

                    managedTankCreature.currentHealth = creature.currentHealth
                    managedTankCreature.lifeTime = creature.lifeTime

                    managedTankCreature.isFavorite = creature.isFavorite

                    managedTankCreature.movementSpeed = creature.movementSpeed
                    managedTankCreature.turnSpeed = creature.turnSpeed
                    managedTankCreature.sizeModifier = creature.sizeModifier
                    managedTankCreature.primaryHue = creature.primaryHue

                    managedTankCreature.positionX = creature.positionX
                    managedTankCreature.positionY = creature.positionY

                    var managedLimbs: [ManagedLimb] = []
                    for limb in creature.limbs {
                        let managedLimb = ManagedLimb(context: self.mainManagedObjectContext)
                        managedLimb.shape = limb.shape.rawValue
                        managedLimb.hue = limb.hue
                        managedLimb.blend = limb.blend
                        managedLimb.brightness = limb.brightness
                        managedLimb.saturation = limb.saturation
                        managedLimb.limbWidth = Int16(limb.limbWidth)

                        managedLimb.wiggleFactor = limb.wiggleFactor
                        managedLimb.wiggleMoveFactor = limb.wiggleMoveFactor
                        managedLimb.wiggleMoveBackFactor = limb.wiggleMoveBackFactor
                        managedLimb.wiggleActionDuration = limb.wiggleActionDuration
                        managedLimb.wiggleActionBackDuration = limb.wiggleActionBackDuration
                        managedLimb.wiggleActionMovementDuration = limb.wiggleActionMovementDuration
                        managedLimb.wiggleActionMovementBackDuration = limb.wiggleActionMovementBackDuration

                        managedLimb.limbzRotation = limb.limbzRotation

                        managedLimb.positionX = limb.positionX
                        managedLimb.positionY = limb.positionY

                        managedLimbs.append(managedLimb)
                    }
                    managedTankCreature.limbs = NSSet(array: managedLimbs)

                    managedCreatures.append(managedTankCreature)
                }
                managedTank.creatures = NSSet(array: managedCreatures)

                var managedBubbles: [ManagedBubble] = []
                for bubble in tank.bubbles {
                    let managedBubble = ManagedBubble(context: self.mainManagedObjectContext)
                    managedBubble.positionY = bubble.positionY
                    managedBubble.positionX = bubble.positionX
                    managedBubbles.append(managedBubble)
                }
                managedTank.bubbles = NSSet(array: managedBubbles)

                var managedFoods: [ManagedFood] = []
                for food in tank.food {
                    let managedFood = ManagedFood(context: self.mainManagedObjectContext)
                    managedFood.positionY = food.positionY
                    managedFood.positionX = food.positionX
                    managedFoods.append(managedFood)
                }
                managedTank.food = NSSet(array: managedFoods)

                let managedTankSettings = ManagedTankSettings(context: self.mainManagedObjectContext)
                managedTankSettings.foodMaxAmount = Int16(tank.tankSettings.foodMaxAmount)
                managedTankSettings.foodHealthRestorationBaseValue = tank.tankSettings.foodHealthRestorationBaseValue
                managedTankSettings.foodSpawnRate = Int16(tank.tankSettings.foodSpawnRate)
                managedTankSettings.creatureInitialAmount = Int16(tank.tankSettings.creatureInitialAmount)
                managedTankSettings.creatureMinimumAmount = Int16(tank.tankSettings.creatureMinimumAmount)
                managedTankSettings.creatureSpawnRate = Int16(tank.tankSettings.creatureSpawnRate)
                managedTankSettings.creatureBirthSuccessRate = tank.tankSettings.creatureBirthSuccessRate
                managedTankSettings.backgroundParticleBirthrate = Int16(tank.tankSettings.backgroundParticleBirthrate)
                managedTankSettings.backgroundParticleLifetime = Int16(tank.tankSettings.backgroundParticleLifetime)

                managedTank.tankSettings = managedTankSettings

                try self.mainManagedObjectContext.save()

                if Log.logLevel == .debug {
                    self.databaseCounts()
                }

            } catch {
                Log.error("Tank failed to save to storage.")
            }
        }
    }
}

// MARK: - Utilities

extension CoreDataStore {

    func databaseCounts() {
        // Outputs counts of stored objects to log
        mainManagedObjectContext.perform {
            do {
                let fetchRequestTanks: NSFetchRequest<ManagedTank> = ManagedTank.fetchRequest()
                let managedTanks = try self.mainManagedObjectContext.fetch(fetchRequestTanks) as [ManagedTank]
                Log.debug("Managed Tanks: \(managedTanks.count)")

                let fetchRequestCreatures: NSFetchRequest<ManagedCreature> = ManagedCreature.fetchRequest()
                let managedCreatures = try self.mainManagedObjectContext.fetch(fetchRequestCreatures) as [ManagedCreature]
                Log.debug("Managed Creatures: \(managedCreatures.count)")

                let fetchRequestBubbles: NSFetchRequest<ManagedBubble> = ManagedBubble.fetchRequest()
                let managedBubbles = try self.mainManagedObjectContext.fetch(fetchRequestBubbles) as [ManagedBubble]
                Log.debug("Managed Bubbles: \(managedBubbles.count)")

                let fetchRequestFoods: NSFetchRequest<ManagedFood> = ManagedFood.fetchRequest()
                let managedFoods = try self.mainManagedObjectContext.fetch(fetchRequestFoods) as [ManagedFood]
                Log.debug("Managed Food: \(managedFoods.count)")
            } catch {
                Log.error("Failed to get object counts.")
            }
        }
    }
}
