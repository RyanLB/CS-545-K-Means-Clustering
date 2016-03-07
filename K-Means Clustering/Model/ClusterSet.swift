//
//  ClusterSet.swift
//  K-Means Clustering
//
//  Created by Ryan Bernstein on 3/5/16.
//  Copyright © 2016 Ryan Bernstein. All rights reserved.
//

import Foundation

class ClusterSet {
    private var _clusters: [Cluster]
    var clusters: [Cluster] {
        get { return _clusters }
    }
    
    init(k: Int) {
        _clusters = [Cluster]()
        for _ in 0..<k {
            _clusters.append(Cluster())
        }
    }
    
    func trainOnData(data: [NumberInstance], maxIterations: Int) throws {
        for _ in 0..<maxIterations {
            if !recenterClustersWithData(data) {
                break
            }
        }
    }
    
    func recenterClustersWithData(data: [NumberInstance]) -> Bool {
        let buckets = bucketInstances(data)
        
        var updated = false
        zip(_clusters, buckets).forEach{
            if $0.0.recenterWithInstances($0.1) {
                updated = true
            }
        }
        
        return updated
    }
    
    func sumSquaredErrorOverData(data: [NumberInstance]) -> Double {
        let buckets = bucketInstances(data)
        return sumSquaredErrorWithBuckets(buckets)
    }
    
    func sumSquaredErrorWithBuckets(buckets: [[NumberInstance]]) -> Double {
        assert(buckets.count == _clusters.count)
        return zip(_clusters, buckets).reduce(0.0, combine: { try! $0 + $1.0.sumSquaredDistanceForInstances($1.1) })
    }
    
    func accuracyOverData(data: [NumberInstance]) -> Double {
        let buckets = bucketInstances(data)
        
        let percentages = buckets.map{ Double($0.count) / Double(data.count) }
        let accuracies = zip(_clusters, buckets).map{ $0.0.accuracyFromData($0.1) }
        return zip(accuracies, percentages).reduce(0.0, combine: { $0 + ($1.0 * $1.1) })
    }
    
    func sumSquaredSeparation() -> Double {
        var separation = 0.0
        for i in 0..<(_clusters.count - 1) {
            for j in i..<_clusters.count {
                try! separation += _clusters[i].center.squaredDistance(_clusters[j].center)
            }
        }
        
        return separation
    }
    
    class func bestOf(tries: Int, fromData: [NumberInstance], withCardinality: Int, andTrainingLimit: Int) throws -> ClusterSet {
        var sets = [ClusterSet]()
        for _ in 0..<tries {
            let cs = ClusterSet(k: withCardinality)
            try cs.trainOnData(fromData, maxIterations: andTrainingLimit)
            sets.append(cs)
        }
        
        let errors = sets.map{ $0.sumSquaredErrorOverData(trainingData) }
        let windex = errors.randomWinnerIndex{ $0 == errors.minElement() }
        
        return sets[windex]
    }
    
    func testOnData(data: [NumberInstance]) -> KMTestResult {
        let buckets = bucketInstances(data)
        let guesses = zip(_clusters, buckets).map{ $0.0.guessFromData($0.1) }
        
        return KMTestResult(clusters: self, buckets: buckets, guesses: guesses)
    }
    
    private func bucketInstances(instances: [NumberInstance]) -> [[NumberInstance]] {
        var buckets = [[NumberInstance]](count: _clusters.count, repeatedValue: [NumberInstance]())
        for i in instances {
            let distances = _clusters.map{ try! $0.center.squaredDistance(i.location) }
            let windex = distances.randomWinnerIndex{ $0 == distances.minElement() }
            buckets[windex].append(i)
        }
        
        return buckets
    }
}