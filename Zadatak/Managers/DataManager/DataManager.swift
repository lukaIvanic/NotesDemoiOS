//
//  DataManager.swift
//  Zadatak
//
//  Created by Luka Ivanić on 28.09.2021..
//

import UIKit
import CoreData

protocol DataManager {
    
    var elements: [Element] { get set }
    func fetchData()
    func saveData()
    func addElement(_ element: Element)
    func deleteElement(_ indexPath: IndexPath)
    func editElement(_ element: Element)
}
