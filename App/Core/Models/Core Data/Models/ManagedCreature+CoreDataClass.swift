//
//  ManagedCreature+CoreDataClass.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/6/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import CoreData
import Foundation

@objc(ManagedCreature)
public class ManagedCreature: NSManagedObject {
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
            isFavorite: true,
            lifeTime: 0,
            currentHealth: 0,
            positionX: 0,
            positionY: 0
        )
    }
}
