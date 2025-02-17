//
//  ReportContentType.swift
//  XClone
//
//  Created by Stephan Dowless on 2/12/25.
//

import Foundation

enum ReportContentType {
    case post(post: Post)
    case account(user: User)
    
    var description: String {
        switch self {
        case .post: return "post"
        case .account: return "account"
        }
    }
}
