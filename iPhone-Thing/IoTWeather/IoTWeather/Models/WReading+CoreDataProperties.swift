//
//  WReading+CoreDataProperties.swift
//  
//
//  Created by steven freed on 8/20/18.
//
//

import Foundation
import CoreData


extension WReading {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WReading> {
        return NSFetchRequest<WReading>(entityName: "WReading")
    }

    @NSManaged public var temp: Int16
    @NSManaged public var view: String?

}
