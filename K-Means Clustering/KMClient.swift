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

class KMClient {
    var trainingData = [NumberInstance]()
    var testData = [NumberInstance]()
    
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