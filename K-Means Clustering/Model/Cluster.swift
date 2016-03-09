//
//  Cluster.swift
//  K-Means Clustering
//
//  Created by Ryan Bernstein on 3/3/16.
//  Copyright © 2016 Ryan Bernstein. All rights reserved.
//

import Foundation

class Cluster {
    var _center: Point
    var center: Point {
        return _center
    }
    
    init() {
        _center = try! Point.RandomPoint(64, withLimit: 16)
    }
    
    init(fromPoint: Point) {
        assert(fromPoint.attributeVector.count == 64)
        _center = fromPoint
    }
    
    /// Returns the most common actual class in the given bucket. Ties are broken at random.
    func guessFromData(data: [NumberInstance]) -> Int {
        var counts = [Int]()
        for i in 0...9 {
            counts.append(data.countWhere{ $0.knownValue == i })
        }
        
        return counts.randomWinnerIndex{ $0 == counts.maxElement() }
    }
    
    /**
     Moves the center of this Cluster to the centroid, assuming they are different.
     
     Returns: A Bool indicating whether or not the centroid moved.
     */
    func recenterWithInstances(instances: [NumberInstance]) -> Bool {
        let c = centroid(instances)
        let updated = c == center
        _center = c
        return updated
    }
    
    /// Finds the mean of the given set of instances. If this bucket is empty, we pick a new center at random.
    private func centroid(instances: [NumberInstance]) -> Point {
        if instances.count == 0 {
            return try! Point.RandomPoint(64, withLimit: 16)
        }
        
        var means = [Double](count: 64, repeatedValue: 0.0)
        for i in 0..<64 {
            means[i] = instances.map{ $0.location[i] }.reduce(0, combine: +) / Double(instances.count)
        }
        
        return try! Point(attributeVector: means)
    }
    
    /// Finds the total distance between this Cluster's center and all of the instances in the given set.
    func sumSquaredDistanceForInstances(instances: [NumberInstance]) throws -> Double {
        return try instances.map{ try center.squaredDistance($0.location) }.reduce(0, combine: +)
    }
}