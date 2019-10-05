//
//  ManagedTankSettings+CoreDataProperties.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/5/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedTankSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedTankSettings> {
        return NSFetchRequest<ManagedTankSettings>(entityName: "ManagedTankSettings")
    }

    @NSManaged public var foodMaxAmount: Int16
    @NSManaged public var foodHealthRestorationBaseValue: Float
    @NSManaged public var foodSpawnRate: Int16
    @NSManaged public var creatureInitialAmount: Int16
    @NSManaged public var creatureMinimumAmount: Int16
    @NSManaged public var creatureSpawnRate: Int16
    @NSManaged public var creatureBirthSuccessRate: Float
    @NSManaged public var tank: ManagedTank?

}
