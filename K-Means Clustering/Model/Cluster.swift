//
//  Cluster.swift
//  K-Means Clustering
//
//  Created by Ryan Bernstein on 3/3/16.
//  Copyright © 2016 Ryan Bernstein. All rights reserved.
//

import Foundation

class Cluster {
    var center: Point
    var members: [NumberInstance]
    
    init() {
        center = try! Point.RandomPoint(64)
        members = []
    }
    
    func guess() -> Int {
        var counts = [Int]()
        for i in 0...9 {
            counts.append(members.countWhere{ $0.knownValue == i })
        }
        
        let winners = counts.indicesWhere{ $0 == counts.maxElement()! }
        return winners[Int(arc4random_uniform(UInt32(winners.count)))]
    }
    
    func centroid() -> Point {
        if members.count == 0 {
            return center
        }
        
        var means = [Float](count: 64, repeatedValue: 0.0)
        for i in 0..<64 {
            means[i] = members.map{ $0.location[i] }.reduce(0, combine: +) / Float(members.count)
        }
        
        return try! Point(attributeVector: means)
    }
    
    func accuracy() -> Float {
        guard members.count > 0 else {
            return 0.0
        }
        
        let g = guess()
        return Float(members.countWhere{ $0.knownValue == g }) / Float(members.count)
    }
    
    func sumSquaredDistance() throws -> Float {
        let c = centroid()
        return try members.reduce(0.0, combine: { try $0 + c.squaredDistance($1.location) })
    }
}