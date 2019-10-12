//
//  ManagedTankSettings+CoreDataProperties.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/6/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import CoreData
import Foundation

extension ManagedTankSettings {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedTankSettings> {
        return NSFetchRequest<ManagedTankSettings>(entityName: "ManagedTankSettings")
    }

    @NSManaged public var creatureBirthSuccessRate: Float
    @NSManaged public var creatureInitialAmount: Int16
    @NSManaged public var creatureMinimumAmount: Int16
    @NSManaged public var creatureSpawnRate: Int16
    @NSManaged public var foodHealthRestorationBaseValue: Float
    @NSManaged public var foodMaxAmount: Int16
    @NSManaged public var foodSpawnRate: Int16
    @NSManaged public var backgroundParticleBirthrate: Int16
    @NSManaged public var backgroundParticleLifetime: Int16
    @NSManaged public var tank: ManagedTank
}

extension ManagedTankSettings {
    func toStruct() -> TankSettings {
        return TankSettings(
            foodMaxAmount: Int(foodMaxAmount),
            foodHealthRestorationBaseValue: foodHealthRestorationBaseValue,
            foodSpawnRate: Int(foodSpawnRate),
            creatureInitialAmount: Int(creatureInitialAmount),
            creatureMinimumAmount: Int(creatureMinimumAmount),
            creatureSpawnRate: Int(creatureSpawnRate),
            creatureBirthSuccessRate: creatureBirthSuccessRate,
            backgroundParticleBirthrate: Int(backgroundParticleBirthrate),
            backgroundParticleLifetime: Int(backgroundParticleLifetime)
        )
    }
}
