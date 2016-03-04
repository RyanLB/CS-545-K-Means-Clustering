//
//  NSArrayExtension.swift
//  perceptron_chars
//
//  Created by Ryan Bernstein on 1/11/16.
//  Copyright © 2016 Ryan Bernstein. All rights reserved.
//

import Foundation

extension Array {
    /**
     Performs a Fisher-Yates shuffle on this array.
     */
    mutating func shuffle() {
        for i in 0..<(self.count - 1) {
            let j = Int(arc4random_uniform(UInt32(self.count - i)))
            let tmp = self[i]
            self[i] = self[i + j]
            self[i + j] = tmp
        }
    }
    
    /**
     Returns the indices of all elements that satisfy the given predicate.
     */
    func indicesWhere(predicate: Element throws -> Bool) rethrows -> [Int] {
        var results = [Int]()
        
        for i in 0..<self.count {
            if try predicate(self[i]) {
                results.append(i)
            }
        }
        
        return results
    }
    
    /// Returns the count of elements that satisfy the given predicate.
    func countWhere(predicate: Element throws -> Bool) rethrows -> Int {
        return try self.reduce(0, combine: {
            if try predicate($1) {
                return $0 + 1
            }
            
            return $0
        })
    }
    
    /// Returns the index of an element satisfying the given predicate. Ties are broken randomly.
    func randomWinnerIndex(winCondition: Element throws -> Bool) rethrows -> Int {
        let winners = try indicesWhere(winCondition)
        
        return winners[Int(arc4random_uniform(UInt32(winners.count)))]
    }
}