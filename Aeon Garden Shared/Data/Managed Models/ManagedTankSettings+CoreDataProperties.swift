//
//  ManagedTankSettings+CoreDataProperties.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/6/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import Foundation
import CoreData


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
            foodMaxAmount: Int(self.foodMaxAmount),
            foodHealthRestorationBaseValue: self.foodHealthRestorationBaseValue,
            foodSpawnRate: Int(self.foodSpawnRate),
            creatureInitialAmount: Int(self.creatureInitialAmount),
            creatureMinimumAmount: Int(self.creatureMinimumAmount),
            creatureSpawnRate: Int(self.creatureSpawnRate),
            creatureBirthSuccessRate: self.creatureBirthSuccessRate,
            backgroundParticleBirthrate: Int(self.backgroundParticleBirthrate),
            backgroundParticleLifetime: Int(self.backgroundParticleLifetime)
        )
    }
}
