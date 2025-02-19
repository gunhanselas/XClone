//
//  ReportPostView.swift
//  XClone
//
//  Created by Stephan Dowless on 2/12/25.
//

import SwiftUI

struct ReportContentView: View {
    @Environment(\.dismiss) private var dismiss
        
    let contentType: ReportContentType
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Report")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding()
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Why are you reporting this \(contentType.description)?")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Your report is anonymous, except if you're reporting an intellectual property infringement. If someone is in immediate danger, call the local emergency services - don't wait.")
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.gray)
                }
                .padding(.vertical)
                .padding(.horizontal, 8)
                
                Divider()
                
                List {
                    ForEach(ReportOptionsModel.allCases) { option in
                        HStack {
                            NavigationLink(value: option) {
                                Text(option.title)
                                    .font(.subheadline)
                                    .padding(.vertical, 12)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            
            .navigationDestination(for: ReportOptionsModel.self) { option in
                ReportSubmittedView(dismiss: dismiss, contentType: contentType, reportReason: option)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    ReportContentView(contentType: .account(user: MockData.currentUser))
}
