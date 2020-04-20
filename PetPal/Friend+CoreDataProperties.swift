//
//  Friend+CoreDataProperties.swift
//  PetPal
//
//  Created by Lab on 1/31/20.
//  Copyright © 2020 Arifeen Mahmud. All rights reserved.
//
//

import Foundation
import CoreData


extension Friend {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Friend> {
        return NSFetchRequest<Friend>(entityName: "Friend")
    }

    @NSManaged public var name: String?

}
