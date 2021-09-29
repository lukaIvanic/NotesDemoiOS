//
//  DataManagerImpl.swift
//  Zadatak
//
//  Created by Luka Ivanić on 29.09.2021..
//


import UIKit
import CoreData


class DataManagerImpl: DataManager {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var elements = [Element]()
    
    func fetchData() {
        
        do {
            let request = Element.fetchRequest() as NSFetchRequest<Element>
            let sort = NSSortDescriptor(key: "index", ascending: true)
            request.sortDescriptors = [sort]
            
            elements = try context.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if elements.isEmpty {
            dummyData()
        }
    }
    
    func saveData(){
        do {
            refreshElementIndexes()
            try context.save()
        } catch  {
            print("saving error: \(error)")
        }
    }
    
    func addElement(_ element: Element) {
        elements.insert(element, at: 0)
        saveData()
        fetchData()
        
    }
    
    func deleteElement(_ indexPath: IndexPath){
        context.delete(elements[indexPath.row])
        elements.remove(at: indexPath.row)
        saveData()
        
    }
    
    func editElement(_ element: Element) {
        elements[Int(element.index)] = element
        saveData()
        
    }
    
}

extension DataManagerImpl {
    
    func refreshElementIndexes(){
        for (i, element) in elements.enumerated() {
            element.index = Int32(i)
        }
    }
    
    func dummyData() {
        
        for i in 1...24 {
            let newElement = Element(context: context)
            newElement.title = "ELEMENT \(i)"
            newElement.tag = ""
            newElement.beginningDate = Date()
            newElement.endingDate = Date()
            newElement.id = UUID()
            newElement.index = Int32(i-1)
            
            elements.append(newElement)
        }
        
    }
    
}
