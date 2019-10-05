//
//  ManagedObject+CoreDataProperties.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/5/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedObject> {
        return NSFetchRequest<ManagedObject>(entityName: "ManagedObject")
    }

    @NSManaged public var positionX: Float
    @NSManaged public var positionY: Float

}
