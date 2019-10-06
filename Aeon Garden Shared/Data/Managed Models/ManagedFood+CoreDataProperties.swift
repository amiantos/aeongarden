//
//  ManagedFood+CoreDataProperties.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/6/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedFood {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedFood> {
        return NSFetchRequest<ManagedFood>(entityName: "ManagedFood")
    }

    @NSManaged public var positionX: Float
    @NSManaged public var positionY: Float
    @NSManaged public var tank: ManagedTank

}
