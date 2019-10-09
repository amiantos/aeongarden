//
//  ManagedTankCreature+CoreDataProperties.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/6/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import CoreData
import Foundation

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

extension ManagedTankCreature {
    func toStruct() -> Creature {
        var limbs: [Limb] = []
        for managedLimb in self.limbs.allObjects as! [ManagedLimb] {
            limbs.append(managedLimb.toStruct())
        }
        return Creature(
            uuid: self.uuid,
            firstName: self.firstName,
            lastName: self.lastName,
            limbs: limbs,
            movementSpeed: self.movementSpeed,
            turnSpeed: self.turnSpeed,
            sizeModifier: self.sizeModifier,
            primaryHue: self.primaryHue,
            isFavorite: self.isFavorite,
            lifeTime: self.lifeTime,
            currentHealth: self.currentHealth,
            positionX: self.positionX,
            positionY: self.positionY
        )
    }
}
