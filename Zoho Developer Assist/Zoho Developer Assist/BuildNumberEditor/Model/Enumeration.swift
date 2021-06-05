//
//  Enumeration.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 05/06/21.
//

import Foundation

enum Postion: Hashable
{
    case other(Int), last
    
    func getString() -> String
    {
        switch self
        {
        case .other(let integer):
            if integer == 1
            {
                return "Major"
            }
            if integer == 2
            {
                return "Minor"
            }
            else
            {
                return "Minor(\(integer - 2))"
            }
        case .last:
            return "Patch"
        }
    }
}

enum BuildNumberType
{
   case plain, combineLastTwoWithHunderMutiple
}


enum UserDefaultKeys: String
{
    case workspaceUrl, workspaceFormattedName, isSelectAllProject, isRemovePodAndFrameworkProject
}
