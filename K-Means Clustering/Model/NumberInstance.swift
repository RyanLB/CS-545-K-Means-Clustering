//
//  NumberInstance.swift
//  K-Means Clustering
//
//  Created by Ryan Bernstein on 3/3/16.
//  Copyright © 2016 Ryan Bernstein. All rights reserved.
//

import Foundation

enum NumberInstanceError : ErrorType {
    case InvalidStringInitializer(str: String)
}

class NumberInstance {
    let knownValue: Int
    let location: Point

    init(knownValue: Int, location: Point) {
        self.knownValue = knownValue
        self.location = location
    }
    
    init(fromLine: String) throws {
        let asArray = fromLine.componentsSeparatedByString(",")
        guard asArray.count == 65 else {
            knownValue = -1
            location = try! Point.RandomPoint(64)
            throw NumberInstanceError.InvalidStringInitializer(str: fromLine)
        }
        
        knownValue = Int(asArray[64])!
        location = try! Point(attributeVector: asArray[0..<64].map{ Double($0)! })
    }
}