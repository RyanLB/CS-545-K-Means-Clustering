//
//  ConfusionMatrix.swift
//  K-Means Clustering
//
//  Created by Ryan Bernstein on 3/8/16.
//  Copyright © 2016 Ryan Bernstein. All rights reserved.
//

import Foundation

struct ConfusionMatrix {
    let data: [(instance: NumberInstance, guess: Int)]
    
    init(data: [(instance: NumberInstance, guess: Int)]) {
        self.data = data
    }
    
    lazy var matrix: [[Int]] = {
        var buckets = [[Int]](count: 10, repeatedValue: [Int](count: 10, repeatedValue: 0))
        
        for example in self.data {
            ++(buckets[example.instance.knownValue][example.guess])
        }
        
        return buckets
    }()
    
    /**
     Generates a representation of this matrix as a string of comma/newline delimited values.
     */
    
    mutating func toCSVString() -> String {
        var str = ""
        for i in 0..<10 {
            for j in 0..<(9) {
                str += "\(matrix[i][j]),"
            }
            str += "\(matrix[i][9])\n"
        }
        
        return str
    }
}