//
//  Element+CoreDataClass.swift
//  
//
//  Created by Luka Ivanić on 28.09.2021..
//
//

import Foundation
import CoreData

@objc(Element)
public class Element: NSManagedObject {

    public func setData(_ element: Element) {
        self.title = element.title
        self.tag = element.tag
        self.beginningDate = element.beginningDate
        self.endingDate = element.endingDate
    }
    
}
