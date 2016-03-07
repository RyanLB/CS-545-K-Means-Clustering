//
//  main.swift
//  K-Means Clustering
//
//  Created by Ryan Bernstein on 3/2/16.
//  Copyright © 2016 Ryan Bernstein. All rights reserved.
//

import Foundation

guard Process.argc >= 3 else {
    print("usage: K-Means\\ Clustering trainingLocation testLocation")
    exit(1)
}

let trainingLocation = Process.arguments[1]
let testLocation = Process.arguments[2]

let trainingData = try loadDataFromFile(trainingLocation)
let testData = try loadDataFromFile(testLocation)

let exp1Set = try ClusterSet.bestOf(5, fromData: trainingData, withCardinality: 10, andTrainingLimit: 10)
let exp1Results = exp1Set.testOnData(testData)
print(exp1Results.accuracy)