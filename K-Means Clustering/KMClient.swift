//
//  KMClient.swift
//  K-Means Clustering
//
//  Created by Ryan Bernstein on 3/3/16.
//  Copyright © 2016 Ryan Bernstein. All rights reserved.
//

import Foundation

enum KMClientError : ErrorType {
    case InvalidFilepath(path: String)
}

struct KMResult {
    let accuracy: Double
    let sumSquaredError: Double
    let sumSquaredSeparation: Double
    let clusters: [Cluster]
    
    init(accuracy: Double, sumSquaredError: Double, sumSquaredSeparation: Double, clusters: [Cluster]) {
        self.accuracy = accuracy
        self.sumSquaredError = sumSquaredError
        self.sumSquaredSeparation = sumSquaredSeparation
        self.clusters = clusters
    }
}

class KMClient {
    var trainingData = [NumberInstance]()
    var testData = [NumberInstance]()
    
    var clusters = [Cluster]()
    
    func train(clusterCount: Int, maxRepetitions: Int) throws -> KMResult {
        clusters = [Cluster]()
        
        for _ in 0..<clusterCount {
            clusters.append(Cluster())
        }
        
        for _ in 0..<maxRepetitions {
            try bucketInstances(trainingData)
            let centersUpdated = updateClusterCenters()
            
            if !centersUpdated {
                break
            }
        }
        
        return KMResult(accuracy: accuracy(),
                        sumSquaredError: try sumSquaredError(),
                        sumSquaredSeparation: try sumSquaredSeparation(),
                        clusters: clusters)
    }
    
    func testAccuracy() throws -> Double {
        try bucketInstances(testData)
        return accuracy()
    }
    
    private func accuracy() -> Double {
        return clusters.reduce(0.0, combine: { $0 + ($1.accuracy() * (Double($1.members.count) / Double(trainingData.count))) })
    }
    
    private func updateClusterCenters() -> Bool {
        var updated = false
        clusters.forEach{
            let newCenter = $0.centroid()
            if newCenter != $0.center {
                updated = true
            }
            $0.center = newCenter
        }
        
        return updated
    }
    
    func sumSquaredError() throws -> Double {
        return try clusters.reduce(0.0, combine: { try $0 + $1.sumSquaredDistance() })
    }
    
    func sumSquaredSeparation() throws -> Double {
        var separation = 0.0
        
        for i in 0..<(clusters.count - 1) {
            let c = clusters[i]
            for j in i..<clusters.count {
                separation += try c.center.squaredDistance(clusters[j].center)
            }
        }
        
        return separation
    }
    
    private func bucketInstances(instances: [NumberInstance]) throws {
        // Clear current membership
        clusters.forEach{ $0.members = [NumberInstance]() }
        
        for i in instances {
            let distances = try clusters.map{ try $0.center.squaredDistance(i.location) }
            let clusterIndex = distances.randomWinnerIndex{ $0 == distances.minElement() }
            
            clusters[clusterIndex].members.append(i)
        }
    }
    
    func loadData(trainingLocation: String, testLocation: String) throws {
        trainingData = try loadData(trainingLocation)
        testData = try loadData(testLocation)
    }
    
    private func loadData(fromFile: String) throws -> [NumberInstance] {
        var instances = [NumberInstance]()
        
        guard let handle = NSFileHandle(forReadingAtPath: fromFile) else {
            throw KMClientError.InvalidFilepath(path: fromFile)
        }
        
        repeat {
            guard let s = handle.getASCIILine() else {
                break
            }
            
            if let newInstance = try? NumberInstance(fromLine: s) {
                instances.append(newInstance)
            }
        } while true
        
        handle.closeFile()
        
        return instances
    }
}