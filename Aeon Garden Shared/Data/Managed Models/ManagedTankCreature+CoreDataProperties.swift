//
//  ManagedTankCreature+CoreDataProperties.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/6/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedTankCreature {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedTankCreature> {
        return NSFetchRequest<ManagedTankCreature>(entityName: "ManagedTankCreature")
    }

    @NSManaged public var lifeTime: Float
    @NSManaged public var isFavorite: Bool
    @NSManaged public var currentHealth: Float
    @NSManaged public var positionX: Float
    @NSManaged public var positionY: Float
    @NSManaged public var tank: ManagedTank

}
