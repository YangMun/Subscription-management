//
//  Login+CoreDataProperties.swift
//  Subscribe
//
//  Created by 양문경 on 9/5/24.
//
//

import Foundation
import CoreData


extension Login {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Login> {
        return NSFetchRequest<Login>(entityName: "Login")
    }

    @NSManaged public var id: String?
    @NSManaged public var password: String?
    @NSManaged public var email: String?

}

extension Login : Identifiable {

}
