//
//  KMTestResult.swift
//  K-Means Clustering
//
//  Created by Ryan Bernstein on 3/6/16.
//  Copyright © 2016 Ryan Bernstein. All rights reserved.
//

import Foundation

struct KMTestResult {
    private let clusters: ClusterSet
    private let buckets: [[NumberInstance]]
    private let guesses: [Int]
    
    init(clusters: ClusterSet, buckets: [[NumberInstance]], guesses: [Int]) {
        self.clusters = clusters
        self.buckets = buckets
        self.guesses = guesses
        assert(clusters.clusters.count == buckets.count && buckets.count == guesses.count)
    }
    
    var accuracy: Double {
        get {
            let bucketsAndGuesses = zip(buckets, guesses).map{ ($0.0, forGuess: $0.1) }
            let clusterAccuracies = zip(clusters.clusters, bucketsAndGuesses).map{ $0.0.accuracyFromData($0.1) }
            
            let total = buckets.map{ $0.count }.reduce(0, combine: +)
            let weights = buckets.map{ Double($0.count) / Double(total) }
            
            return zip(clusterAccuracies, weights).map{ $0.0 * $0.1 }.reduce(0, combine: +)
        }
    }
    
    var sumSquaredError: Double {
        get {
            return clusters.sumSquaredErrorWithBuckets(buckets)
        }
    }
    
    var sumSquaredDistance: Double {
        return clusters.sumSquaredSeparation()
    }
    
}