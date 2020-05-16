//
//  PostError.swift
//  Continuum
//
//  Created by Jimmy on 5/12/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import Foundation


enum PostError: LocalizedError {
    
    case ckError(Error)
    case noRecord
    case noPost
    case couldNotUnwrap
    case couldNotDeleteSubscription
    
    var localizedDescription: String {
        switch self {
            
        case .ckError(let error):
            return error.localizedDescription
        case .noRecord:
            return "Unable to get from CloudKit"
        case .noPost:
            return "Post not found"
        case .couldNotUnwrap:
            return "Unable to get this post"
        case .couldNotDeleteSubscription:
            return "Could not delete subscription"
        }
    }
    
    
    
    
    
}
