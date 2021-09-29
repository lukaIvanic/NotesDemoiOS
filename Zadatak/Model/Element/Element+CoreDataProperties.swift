//
//  Element+CoreDataProperties.swift
//  
//
//  Created by Luka Ivanić on 28.09.2021..
//
//

import Foundation
import CoreData


extension Element {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Element> {
        return NSFetchRequest<Element>(entityName: "Element")
    }

    @NSManaged public var beginningDate: Date?
    @NSManaged public var endingDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var tag: String?
    @NSManaged public var title: String?
    @NSManaged public var index: Int32

}
