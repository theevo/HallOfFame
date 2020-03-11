//
//  PersonError.swift
//  HallOfFame
//
//  Created by theevo on 3/11/20.
//  Copyright © 2020 theevo. All rights reserved.
//

import Foundation

enum PersonError: LocalizedError {
    case thrown(Error)
    case invalidURL
    case noData
    case badData
    
    var errorDescription: String? {
        switch self {
            
        case .thrown(let error):
            return error.localizedDescription
        case .invalidURL:
            return "Unable to reach server."
        case .noData:
            return "Server responded with no data."
        case .badData:
            return "Server returned bad data."
        }
    } // end errorDescription
} // end enum
