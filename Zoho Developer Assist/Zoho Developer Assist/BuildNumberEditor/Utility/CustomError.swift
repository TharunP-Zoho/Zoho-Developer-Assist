//
//  CustomError.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 05/06/21.
//

import Foundation

struct CustomError: Error
{
    var title: String
    var description: String
}

extension Result
{
    func resultWithCustomError(errorTitle: String) -> Result<Success, CustomError>
    {
        switch self {
        case .success(let sucess):
            return .success(sucess)
        case .failure(let error):
            return .failure(CustomError(title: errorTitle, description: error.localizedDescription))
        }
    }
}
