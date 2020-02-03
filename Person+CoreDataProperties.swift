//
//  Person+CoreDataProperties.swift
//  CoreDataDevices
//
//  Created by Arifeen Mahmud on 2/2/20.
//  Copyright © 2020 Arifeen Mahmud. All rights reserved.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var age: Double
    @NSManaged public var name: String?

}
