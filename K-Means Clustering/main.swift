//
//  main.swift
//  K-Means Clustering
//
//  Created by Ryan Bernstein on 3/2/16.
//  Copyright © 2016 Ryan Bernstein. All rights reserved.
//

import Foundation

var trainingLocation: String
var testLocation: String
var imageLocation: String

if Process.argc >= 4 {
    trainingLocation = Process.arguments[1]
    testLocation = Process.arguments[2]
    imageLocation = Process.arguments[3]
}
else {
    let userInputHandle = NSFileHandle.fileHandleWithStandardInput()
    print("Enter training data location: ")
    trainingLocation = String(data: userInputHandle.availableData, encoding: NSASCIIStringEncoding)!
    print("Enter test data location: ")
    testLocation = String(data: userInputHandle.availableData, encoding: NSASCIIStringEncoding)!
    print("Enter output location (for cluster visualizations): ")
    imageLocation = String(data: userInputHandle.availableData, encoding: NSASCIIStringEncoding)!
    userInputHandle.closeFile()
}

let trainingData = try loadDataFromFile(trainingLocation)
let testData = try loadDataFromFile(testLocation)

let exp1Set = try ClusterSet.bestOf(5, fromData: trainingData, withCardinality: 30, andTrainingLimit: 50)
var exp1Results = exp1Set.testOnData(testData)
print("Accuracy: \(exp1Results.accuracy)")
print("SSE: \(exp1Results.sumSquaredError)")
print("SSS: \(exp1Results.sumSquaredDistance)")
print("Mean entropy: \(exp1Results.meanEntropy)")
exp1Set.visualizedWithRowsOf(5).writeToFile(imageLocation, atomically: false)

for c in exp1Set.clusters {
    print(c.center.attributeVector)
}