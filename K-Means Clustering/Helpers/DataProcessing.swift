//
//  DataProcessing.swift
//  K-Means Clustering
//
//  Created by Ryan Bernstein on 3/5/16.
//  Copyright © 2016 Ryan Bernstein. All rights reserved.
//

import Foundation

enum DataProcessingError : ErrorType {
    case InvalidFilepath(path: String)
}

func loadDataFromFile(file: String) throws -> [NumberInstance] {
    var instances = [NumberInstance]()
    
    guard let handle = NSFileHandle(forReadingAtPath: file) else {
        throw DataProcessingError.InvalidFilepath(path: file)
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