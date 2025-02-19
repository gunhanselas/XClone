//
//  ReportContentManager.swift
//  XClone
//
//  Created by Stephan Dowless on 2/19/25.
//

import Foundation

@Observable
class ReportContentManager {
    private let service: ReportContentService
    
    init(service: ReportContentService) {
        self.service = service
    }
    
    func uploadReport(type: ReportContentType, reason: ReportOptionsModel) async {
        let accountOwnerID: String
        let reportType: ReportType
        var postId: String?
        
        switch type {
        case .post(let post):
            reportType = .post
            postId = post.id
            accountOwnerID = post.authorID
            
        case .account(let user):
            reportType = .account
            accountOwnerID = user.id
        }
        
        do {
            try await service.uploadReport(type: reportType, reason: reason, accountOwnerID: accountOwnerID, postID: postId)
        } catch {
            print("DEBUG: Failed to upload report with error: \(error.localizedDescription)")
        }
    }
}
