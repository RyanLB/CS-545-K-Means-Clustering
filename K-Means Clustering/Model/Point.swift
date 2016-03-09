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
    
    /// Calculates the Euclidean distance between this Point and the argument
    func distance(p2: Point) throws -> Double {
        return sqrt(try squaredDistance(p2))
    }
    
    /// Calculates squared distance between this Point and the argument.
    func squaredDistance(p2: Point) throws -> Double {
        guard dimensions == p2.dimensions else {
            throw PointErrors.MismatchedLengthError(expected: dimensions, found: p2.dimensions)
        }
        
        return zip(attributeVector, p2.attributeVector).map{ pow($0.1 - $0.0, 2) }.reduce(0, combine: +)
    }
    
    /**
     Creates a random vector with the given dimensionality.
     
     Parameter dimensions: The length of the generated vector.
     
     Parameter withLimit: The upper bound for this Vector's entries. 
     */
    static func RandomPoint(dimensions: Int, withLimit: Double) throws -> Point {
        guard dimensions > 0 else {
            throw PointErrors.NegativeLengthException(length: dimensions)
        }
        
        assert(withLimit > 0)
        
        var attributes = [Double]()
        
        for _ in 0..<dimensions {
            attributes.append((Double(arc4random_uniform(100) + 1) / 100.0))
        }
        
        return try Point(attributeVector: attributes.map{ $0 * withLimit })
    }
}