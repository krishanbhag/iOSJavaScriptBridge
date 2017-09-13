//
//  User+CoreDataProperties.swift
//  JSIOSBridgeSwift
//
//  Created by Krishna Shanbhag on 13/09/17.
//  Copyright © 2017 WireCamp Interactive. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var name: String?
    @NSManaged public var lastName: String?

}
