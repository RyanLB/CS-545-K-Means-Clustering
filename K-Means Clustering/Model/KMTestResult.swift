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
    
    // Lazy calculation of numeric result properties.
    // Swift has language support for lazy properties, but it appears to be bugged for structs at the moment.
    private var _accuracy: Double?
    private var _sumSquaredError: Double?
    private var _sumSquaredDistance: Double?
    private var _meanEntropy: Double?
    
    init(clusters: ClusterSet, buckets: [[NumberInstance]], guesses: [Int]) {
        self.clusters = clusters
        self.buckets = buckets
        self.guesses = guesses
        
        assert(clusters.clusters.count == buckets.count && buckets.count == guesses.count)
    }
    
    var accuracy: Double {
        mutating get {
            if _accuracy == nil {
            
                let bucketsAndGuesses = zip(buckets, guesses).map{ ($0.0, forGuess: $0.1) }
                let clusterAccuracies = zip(clusters.clusters, bucketsAndGuesses).map{ $0.0.accuracyFromData($0.1) }
                
                let total = buckets.map{ $0.count }.reduce(0, combine: +)
                let weights = buckets.map{ Double($0.count) / Double(total) }
                
                _accuracy = zip(clusterAccuracies, weights).map{ $0.0 * $0.1 }.reduce(0, combine: +)
            }
            
            return _accuracy!
        }
    }
    
    var sumSquaredError: Double {
        mutating get {
            if _sumSquaredError == nil {
                _sumSquaredError = clusters.sumSquaredErrorWithBuckets(buckets)
            }
            
            return _sumSquaredError!
        }
    }
    
    var sumSquaredDistance: Double {
        mutating get {
            if _sumSquaredDistance == nil {
                _sumSquaredDistance = clusters.sumSquaredSeparation()
            }
            
            return _sumSquaredDistance!
        }
    }
    
    var meanEntropy: Double {
        mutating get {
            if _meanEntropy == nil {
                let totalInstances = Double(buckets.map{ $0.count }.reduce(0, combine: +))
                _meanEntropy = (buckets.map{ Double($0.count) * entropyOfBucket($0) }.reduce(0, combine: +)) / totalInstances
            }
            
            return _meanEntropy!
        }
    }
    
    private func entropyOfBucket(bucket: [NumberInstance]) -> Double {
        var entropy = 0.0
        let totalInstances = Double(bucket.count)
        for i in 0..<10 {
            let count = Double(bucket.countWhere{ $0.knownValue == i })
            
            if count > 0 {
                let p = count / totalInstances
                entropy += p * log2(p)
            }
        }
        
        return -entropy
    }
    
}