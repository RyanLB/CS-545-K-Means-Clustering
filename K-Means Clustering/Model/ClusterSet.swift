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
    
    init(k: Int, distributedThroughoutPoints: [Point]) {
        _clusters = [Cluster()]
        for _ in 1..<k {
            _clusters.append(Cluster(fromPoint: mostRemoteOfPoints(distributedThroughoutPoints)))
        }
    }
    
    /// Repeatedly bucket instances and recenter clusters until cluster centers stop moving.
    func trainOnData(data: [NumberInstance], maxIterations: Int) throws {
        for _ in 0..<maxIterations {
            if !recenterClustersWithData(data) {
                break
            }
        }
    }
    
    /**
     Assigns instances to the closest cluster center, then recenters clusters to the centroid of the points
     that have been assigned to it.
     */
    private func recenterClustersWithData(data: [NumberInstance]) -> Bool {
        let buckets = bucketInstances(data)
        
        var updated = false
        zip(_clusters, buckets).forEach{
            if $0.0.recenterWithInstances($0.1) {
                updated = true
            }
        }
        
        return updated
    }
    
    /// Finds the point in the dataset furthest from any existing cluster centers
    private func mostRemoteOfPoints(points: [Point]) -> Point {
        let smallestDistances = points.map{ minDistanceToClusterCenterFromPoint($0) }
        let windex = smallestDistances.randomWinnerIndex{ $0 == smallestDistances.maxElement() }
        return points[windex]
    }
    
    /// Finds the shortest distance from a given point to any cluster center.
    private func minDistanceToClusterCenterFromPoint(point: Point) -> Double {
        return _clusters.map{ try! $0.center.squaredDistance(point) }.minElement()!
    }
    
    /// Buckets the data and computes the sum squared error for the entire cluster set
    func sumSquaredErrorOverData(data: [NumberInstance]) -> Double {
        let buckets = bucketInstances(data)
        return sumSquaredErrorWithBuckets(buckets)
    }
    
    /// Computes sum squared error for the entire clustering with the given bucketing
    func sumSquaredErrorWithBuckets(buckets: [[NumberInstance]]) -> Double {
        assert(buckets.count == _clusters.count)
        return zip(_clusters, buckets).map{ try! $0.0.sumSquaredDistanceForInstances($0.1) }.reduce(0, combine: +)
    }
    
    /// Computes the total distance between all pairs of cluster centers
    func sumSquaredSeparation() -> Double {
        var separation = 0.0
        for i in 0..<(_clusters.count - 1) {
            for j in (i + 1)..<_clusters.count {
                try! separation += _clusters[i].center.squaredDistance(_clusters[j].center)
            }
        }
        
        return separation
    }
    
    /**
     For `tries` iterations, creates and trains a clustering using random initial centers.
     
     Returns: The ClusterSet with the smallest sum squared error over the training data.
     */
    class func bestOf(tries: Int, fromData: [NumberInstance], withCardinality: Int, andTrainingLimit: Int) throws -> ClusterSet {
        var sets = [ClusterSet]()
        for _ in 0..<tries {
            let cs = ClusterSet(k: withCardinality, distributedThroughoutPoints: fromData.map{ $0.location })
            try cs.trainOnData(fromData, maxIterations: andTrainingLimit)
            sets.append(cs)
        }
        
        let errors = sets.map{ $0.sumSquaredErrorOverData(trainingData) }
        let windex = errors.randomWinnerIndex{ $0 == errors.minElement() }
        
        return sets[windex]
    }
    
    /// Bundles up a ClusterSet, buckets of Instances, and bucket predictions over the given dataset.
    func testOnData(data: [NumberInstance]) -> KMTestResult {
        let buckets = bucketInstances(data)
        let guesses = zip(_clusters, buckets).map{ $0.0.guessFromData($0.1) }
        
        return KMTestResult(clusters: self, buckets: buckets, guesses: guesses)
    }
    
    /**
     Buckets each instance in the dataset by the closest cluster center.
     
     Returns: An array of buckets ordered by closest cluster index.
     */
    private func bucketInstances(instances: [NumberInstance]) -> [[NumberInstance]] {
        var buckets = [[NumberInstance]](count: _clusters.count, repeatedValue: [NumberInstance]())
        for i in instances {
            let distances = _clusters.map{ try! $0.center.squaredDistance(i.location) }
            let windex = distances.randomWinnerIndex{ $0 == distances.minElement() }
            buckets[windex].append(i)
        }
        
        return buckets
    }
    
    /// Turns each cluster center into a matrix of greyscale pixel intensity values for writing to a .pgm file.
    func visualizedWithRowsOf(length: Int) -> NSData {
        let padding = Cluster(fromPoint: try! Point(attributeVector: [Double](count: 64, repeatedValue: 0.0)))
        
        var paddedClusters = _clusters
        
        var rowCount = _clusters.count / length
        if _clusters.count % length != 0 {
            paddedClusters += [Cluster](count: _clusters.count - (_clusters.count % length), repeatedValue: padding)
            ++rowCount
        }
        
        var dataString = "P2\n\(length * 8) \(rowCount * 8)\n255\n"
        
        for i in 0..<rowCount {
            let base = i * length
            let row = Array(_clusters[base..<(base + length)])
            dataString += visualizedRow(row)
        }
        
        return (dataString as NSString).dataUsingEncoding(NSASCIIStringEncoding)!
    }
    
    /// Converts a row of clusters to a string representing pixel intensities for writing to a .pgm file.
    private func visualizedRow(row: [Cluster]) -> String {
        var dataString = ""
        for line in 0..<8 {
            let base = line * 8
            let lineValues = row.map{ Array($0.center.attributeVector[base..<(base + 8)]) }.flatten()
            let lineString = lineValues.map{ String(UInt8(($0 / 16) * 255)) }.joinWithSeparator(" ")
            dataString += lineString + "\n"
        }
        
        return dataString
    }
}