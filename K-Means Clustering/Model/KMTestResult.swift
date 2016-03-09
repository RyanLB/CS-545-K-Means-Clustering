//
//  KMTestResult.swift
//  K-Means Clustering
//
//  Since this assignment breaks ties at random in several places, this struct is used to bundle
//  a clustering result with predictions and remove nondeterminism so that calculations can be done on a
//  static set of classifications.
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
                let clusterAccuracies = zip(buckets, guesses).map{ accuracyForBucket($0.0, withGuess: $0.1) }
                
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
    
    /// Generates and returns a confusion matrix for this bucketing
    func generateConfusionMatrix() -> ConfusionMatrix {
        let classifiedInstances = Array(zip(buckets, guesses).map{ instancesFromBucket($0.0, withGuess: $0.1) }.flatten())
        return ConfusionMatrix(data: classifiedInstances)
    }
    
    /// Returns the percentage of bucketed instances whose actual class matches the given guess.
    private func accuracyForBucket(bucket: [NumberInstance], withGuess: Int) -> Double {
        guard bucket.count > 0 else {
            return 0.0
        }
        
        return Double(bucket.countWhere{ $0.knownValue == withGuess }) / Double(bucket.count)
    }
    
    /// Calculates the entropy of a single cluster.
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
    
    /// Helper function that bundles up instances and guesses for a given bucket.
    private func instancesFromBucket(bucket: [NumberInstance], withGuess: Int) -> [(instance: NumberInstance, guess: Int)] {
        return bucket.map{ (instance: $0, guess: withGuess) }
    }
    
}