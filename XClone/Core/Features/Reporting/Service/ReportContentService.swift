//
//  ReportContentService.swift
//  XClone
//
//  Created by Stephan Dowless on 2/12/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

struct ReportContentService {
    func uploadReport(type: ReportType, reason: ReportOptionsModel, accountOwnerID: String, postID: String? = nil) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let report = Report(
            reporterUid: currentUid,
            type: type,
            postId: postID,
            accountOwnerUid: accountOwnerID,
            reportReason: reason
        )
        
        let data = try Firestore.Encoder().encode(report)
        try await FirestoreConstants.ReportsCollection.document().setData(data)
    }
}
