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

print(trainingLocation)
print(testLocation)

let client = KMClient()

try! client.loadData(trainingLocation, testLocation: testLocation)

print("\(client.trainingData.count) \(client.testData.count)")