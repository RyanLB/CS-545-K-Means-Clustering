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
        _center = try! Point.RandomPoint(64)
    }
    
    init(fromPoint: Point) {
        assert(fromPoint.attributeVector.count == 64)
        _center = fromPoint
    }
    
    func guessFromData(data: [NumberInstance]) -> Int {
        var counts = [Int]()
        for i in 0...9 {
            counts.append(data.countWhere{ $0.knownValue == i })
        }
        
        return counts.randomWinnerIndex{ $0 == counts.maxElement() }
    }
    
    func recenterWithInstances(instances: [NumberInstance]) -> Bool {
        let c = centroid(instances)
        let updated = c == center
        _center = c
        return updated
    }
    
    private func centroid(instances: [NumberInstance]) -> Point {
        if instances.count == 0 {
            return center
        }
        
        var means = [Double](count: 64, repeatedValue: 0.0)
        for i in 0..<64 {
            means[i] = instances.map{ $0.location[i] }.reduce(0, combine: +) / Double(instances.count)
        }
        
        return try! Point(attributeVector: means)
    }
    
    func accuracyFromData(data: [NumberInstance]) -> Double {
        return accuracyFromData(data, forGuess: guessFromData(data))
    }
    
    func accuracyFromData(data: [NumberInstance], forGuess: Int) -> Double {
        guard data.count > 0 else {
            return 0.0
        }
        
        return Double(data.countWhere{ $0.knownValue == forGuess }) / Double(data.count)
    }
    
    func sumSquaredDistanceForInstances(instances: [NumberInstance]) throws -> Double {
        return try instances.reduce(0.0, combine: { try $0 + center.squaredDistance($1.location) })
    }
    
    func visualized() -> NSData {
        var bytes = "P2\n8 8\n255\n"
        let pixelValues = center.attributeVector.map{ String(UInt8(($0 / 16) * 255)) }
        for i in 0..<8 {
            let base = i * 8
            bytes += pixelValues[base..<(base + 8)].reduce("", combine: +) + "\n"
        }
        return (bytes as NSString).dataUsingEncoding(NSASCIIStringEncoding)!
    }
}