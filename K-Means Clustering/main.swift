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
var outputDirectory: String

if Process.argc >= 4 {
    trainingLocation = Process.arguments[1]
    testLocation = Process.arguments[2]
    outputDirectory = Process.arguments[3]
}
else {
    let userInputHandle = NSFileHandle.fileHandleWithStandardInput()
    print("Enter training data location: ")
    trainingLocation = String(data: userInputHandle.availableData, encoding: NSASCIIStringEncoding)!
    print("Enter test data location: ")
    testLocation = String(data: userInputHandle.availableData, encoding: NSASCIIStringEncoding)!
    print("Enter output location (for cluster visualizations): ")
    outputDirectory = String(data: userInputHandle.availableData, encoding: NSASCIIStringEncoding)!
    userInputHandle.closeFile()
}

let trainingData = try loadDataFromFile(trainingLocation)
let testData = try loadDataFromFile(testLocation)

//let exp1Set = try ClusterSet.bestOf(5, fromData: trainingData, withCardinality: 10, andTrainingLimit: 1000)
let exp1Set = ClusterSet(k: 10, distributedThroughoutPoints: trainingData.map{ $0.location })
try exp1Set.trainOnData(trainingData, maxIterations: 1000)
var trainingResults = exp1Set.testOnData(trainingData)
print("Training SSE: \(trainingResults.sumSquaredError)")
print("Training SSS: \(trainingResults.sumSquaredDistance)")
print("Mean entropy: \(trainingResults.meanEntropy)")
var exp1Results = exp1Set.testOnData(testData)
print("Accuracy: \(exp1Results.accuracy)")
exp1Set.visualizedWithRowsOf(5).writeToFile(outputDirectory + "/10.pgm", atomically: false)

var exp1Mat = exp1Results.generateConfusionMatrix()
(exp1Mat.toCSVString() as NSString).dataUsingEncoding(NSASCIIStringEncoding)!.writeToFile(outputDirectory + "/10mat.csv", atomically: false)


print("\nExperiment 2")
//let exp2Set = try ClusterSet.bestOf(5, fromData: trainingData, withCardinality: 30, andTrainingLimit: 1000)
let exp2Set = ClusterSet(k: 30, distributedThroughoutPoints: trainingData.map{ $0.location })
try exp2Set.trainOnData(trainingData, maxIterations: 1000)
trainingResults = exp2Set.testOnData(trainingData)
print("Training SSE: \(trainingResults.sumSquaredError)")
print("Training SSS: \(trainingResults.sumSquaredDistance)")
print("Mean entropy: \(trainingResults.meanEntropy)")
var exp2Results = exp2Set.testOnData(testData)
print("Accuracy: \(exp2Results.accuracy)")
exp2Set.visualizedWithRowsOf(5).writeToFile(outputDirectory + "/30.pgm", atomically: false)

var exp2Mat = exp2Results.generateConfusionMatrix()
(exp2Mat.toCSVString() as NSString).dataUsingEncoding(NSASCIIStringEncoding)!.writeToFile(outputDirectory + "/30mat.csv", atomically: false)
