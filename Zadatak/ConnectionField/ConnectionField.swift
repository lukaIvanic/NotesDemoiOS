//
//  ConnectionField.swift
//  Zadatak
//
//  Created by Luka Ivanić on 29.09.2021..
//

import Foundation

struct ConnectionField {
    
    
    private var activeConnectionField: [[Bool]]! // represents the active connections of the index cell
    private var tagPairs: [Int: [Int]]! // Int is index, [Int] are indexes it's connected with
    
    init(_ elements: [Element]){
        self.set(elements)
    }
    
    
    mutating func findConnections(_ elements: [Element]) -> ([Connection]) {
        
        set(elements)
        
        var actualConnections = [Connection]()
        
        for i1 in 0..<elements.count{
            for i2 in i1+1..<elements.count{
                
                if elements[i1].tag == elements[i2].tag,
                   elements[i1].tag != nil,
                   elements[i1].tag != ""{
                    tagPairs[i1]?.append(i2)
                    
                    if let newConnection = checkForPossibleConnection(i1, i2){
                        actualConnections.append(newConnection)
                    }
                    
                }
            }
        }
        
        return actualConnections
    }
    
}

extension ConnectionField {
    
    private mutating func set(_ elements: [Element]){
        
        activeConnectionField = []
        tagPairs = [Int: [Int]]()
        
        for i in 0..<elements.count {
            activeConnectionField.append([Bool](repeating: false, count: possibleConnectionsOverRow))
            tagPairs[i] = [Int]()
        }
        
        
    }
    
    private mutating func checkForPossibleConnection(_ i1: Int, _ i2: Int) -> Connection?{
        
        var positions = [Bool](repeating: false, count: possibleConnectionsOverRow)
        
        for i in i1...i2 {
            for j in 0..<positions.count{
                positions[j] = activeConnectionField[i][j] || positions[j]
            }
        }
        
    
        let actualPosition = positions.firstIndex { isTaken in !isTaken }
        guard let actualPosition = actualPosition else { return nil }
        
        for i in i1...i2 {
            activeConnectionField[i][actualPosition] = true
        }
        
        return Connection(firstIndex: i1, secondIndex: i2, position: actualPosition)
    }
    
}


