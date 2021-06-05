//
//  ProgressItem.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 05/06/21.
//

import Foundation

struct ProgressItem
{
    enum State
    {
        case completed, failed, processing
    }
    var itemName: String
    var state: State
}

extension Array where Element == ProgressItem
{
    mutating func markAllCompleted()
    {
        for (index, _) in self.enumerated()
        {
                self[index].state = .completed
        }
    }
    mutating func markOthersAsFailed()
    {
        for (index, progressItem) in self.enumerated()
        {
            if progressItem.state == .processing
            {
                self[index].state = .failed
            }
        }
    }
}
