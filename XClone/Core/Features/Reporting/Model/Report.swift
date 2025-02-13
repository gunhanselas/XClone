//
//  Report.swift
//  XClone
//
//  Created by Stephan Dowless on 2/12/25.
//

import Foundation

struct Report: Codable {
    let reporterUid: String
    let type: ReportType
    var postId: String?
    let accountOwnerUid: String
    let reportReason: ReportOptionsModel
}
