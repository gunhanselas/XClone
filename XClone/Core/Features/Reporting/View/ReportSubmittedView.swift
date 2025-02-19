//
//  ReportSubmittedView.swift
//  XClone
//
//  Created by Stephan Dowless on 2/12/25.
//

import SwiftUI

struct ReportSubmittedView: View {
    @State private var isLoading = false
    @State private var manager = ReportContentManager(service: ReportContentService())
    
    let dismiss: DismissAction
    let contentType: ReportContentType
    let reportReason: ReportOptionsModel
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .fontWeight(.light)
                    .frame(width: 64, height: 64)
                    .foregroundStyle(.green)
                
                Text("Thanks for letting us know")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("We use these report to:")
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
            .padding(.top, 24)
            
            VStack(alignment: .leading, spacing: 24) {
                InlineInfoItemView(subtitle: "Understand problems people are having with different types of content on X.", imageName: "info.circle")
                InlineInfoItemView(subtitle: "Show you less of this content in the future.", imageName: "eye.slash")
            }
            .padding()
            
            Spacer()
            
            Divider()
            
            XButton("Next") {
                uploadReport()
            }
            .buttonStyle(.standard, isLoading: $isLoading)
            .disabled(isLoading)

        }
        .presentationDetents([.height(480)])
    }
}

private extension ReportSubmittedView {
    func uploadReport() {
        Task {
            isLoading = true
            await manager.uploadReport(type: contentType, reason: reportReason)
            dismiss()
            isLoading = false
        }
    }
}
