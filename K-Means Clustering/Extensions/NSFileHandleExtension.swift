//
//  NSFileHandleExtension.swift
//  perceptron_chars
//
//  Created by Ryan Bernstein on 1/8/16.
//  Copyright © 2016 Ryan Bernstein. All rights reserved.
//

import Foundation

extension NSFileHandle {
    /**
     Gets a single ASCII-encoded character from the input stream.
     
     - Returns: The Character in question, or `nil` if no characters are available.
     */
    func getASCIIChar() -> Character? {
        let byteData = readDataOfLength(1)
        
        guard byteData.length > 0 else {
            return nil
        }
        
        let dataString = String(data: byteData, encoding: NSASCIIStringEncoding)
        
        return dataString?[(dataString?.startIndex)!]
    }
    
    /**
     Gets an ASCII-encoded line from the input stream, delimited by `\n` or `EOF`.
     
     - Returns: The resulting String. Returns `nil` if no input was available or the line was empty.
     */
    func getASCIILine() -> String? {
        var chars = ""
        
        while let c = getASCIIChar() {
            if c == "\n" {
                return chars
            }
            
            chars.append(c)
        }
        
        return chars == "" ? nil : chars
    }
}