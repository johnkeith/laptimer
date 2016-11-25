//
//  ArrayExtensions.swift
//  LapTimer
//
//  Created by John Keith on 11/23/16.
//  Copyright © 2016 John Keith. All rights reserved.
//

import Foundation

extension Array {
    func chunk(chunkSize: Int) -> [[Any]] {
        return stride(from: 0, to: self.count, by: chunkSize).map({ (startIndex) -> [Any] in
            let endIndex = (startIndex.advanced(by: chunkSize) > self.count) ? self.count-startIndex : chunkSize
            return Array(self[startIndex..<startIndex.advanced(by: endIndex)])
        })
    }
}
