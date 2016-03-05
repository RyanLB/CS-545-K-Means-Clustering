//
//  Point.swift
//  K-Means Clustering
//
//  Created by Ryan Bernstein on 3/3/16.
//  Copyright © 2016 Ryan Bernstein. All rights reserved.
//

import Foundation
import Accelerate

enum PointErrors : ErrorType {
    case MismatchedLengthError(expected: Int, found: Int)
    case NegativeLengthException(length: Int)
}

func == (left: Point, right: Point) -> Bool {
    return left.attributeVector == right.attributeVector
}

func != (left: Point, right: Point) -> Bool {
    return left.attributeVector != right.attributeVector
}

struct Point {
    let attributeVector: [Double]
    let dimensions: Int
    
    subscript(index: Int) -> Double {
        get { return attributeVector[index] }
    }
    
    init(attributeVector: [Double]) throws {
        self.dimensions = attributeVector.count
        self.attributeVector = attributeVector
        
        guard dimensions > 0 else {
            throw PointErrors.NegativeLengthException(length: dimensions)
        }
    }
    
    func distance(p2: Point) throws -> Double {
        return sqrt(try squaredDistance(p2))
    }
    
    func squaredDistance(p2: Point) throws -> Double {
        guard dimensions == p2.dimensions else {
            throw PointErrors.MismatchedLengthError(expected: dimensions, found: p2.dimensions)
        }
        
        return zip(attributeVector, p2.attributeVector).reduce(0.0, combine: { $0 + pow($1.1 - $1.0, 2) })
    }
    
    static func RandomPoint(dimensions: Int) throws -> Point {
        guard dimensions > 0 else {
            throw PointErrors.NegativeLengthException(length: dimensions)
        }
        
        var attributes = [Double]()
        
        for _ in 0..<dimensions {
            attributes.append(1.0 / Double(arc4random()))
        }
        
        return try Point(attributeVector: attributes)
    }
}