//
//  ManagedBubble+CoreDataProperties.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/6/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedBubble {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedBubble> {
        return NSFetchRequest<ManagedBubble>(entityName: "ManagedBubble")
    }

    @NSManaged public var positionX: Float
    @NSManaged public var positionY: Float
    @NSManaged public var tank: ManagedTank

}

extension ManagedBubble {
    func toStruct() -> Bubble {
        return Bubble(positionX: self.positionX, positionY: self.positionY)
    }
}
