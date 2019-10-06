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
    @NSManaged public var creatureInitialAmount: Int
    @NSManaged public var creatureMinimumAmount: Int
    @NSManaged public var creatureSpawnRate: Int
    @NSManaged public var foodHealthRestorationBaseValue: Float
    @NSManaged public var foodMaxAmount: Int
    @NSManaged public var foodSpawnRate: Int
    @NSManaged public var backgroundParticleBirthrate: Int
    @NSManaged public var backgroundParticleLifetime: Int
    @NSManaged public var tank: ManagedTank

}
