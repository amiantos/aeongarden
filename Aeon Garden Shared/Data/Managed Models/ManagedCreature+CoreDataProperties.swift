//
//  ManagedCreature+CoreDataProperties.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/6/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedCreature {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedCreature> {
        return NSFetchRequest<ManagedCreature>(entityName: "ManagedCreature")
    }

    @NSManaged public var firstName: String
    @NSManaged public var lastName: String
    @NSManaged public var movementSpeed: Float
    @NSManaged public var primaryHue: Float
    @NSManaged public var sizeModifier: Float
    @NSManaged public var turnSpeed: Float
    @NSManaged public var uuid: UUID?

}
