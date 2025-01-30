//
//  ReplySortSelectionView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import SwiftUI

struct ReplySortSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedReplySortOption: ReplySortModel
    
    var body: some View {
        VStack {
            Text("Sort Replies")
                .font(.headline)
                .padding()
            
            VStack(spacing: 16) {
                ForEach(ReplySortModel.allCases) { model in
                    HStack {
                        Text(model.description)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Image(systemName: model == selectedReplySortOption ? "checkmark.circle.fill" : "circle")
                            .imageScale(.large)
                            .foregroundStyle(model == selectedReplySortOption ? .primaryBlue : .gray)
                    }
                    .padding(.horizontal)
                    .onTapGesture {
                        selectedReplySortOption = model
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable
    @State var selected: ReplySortModel = .mostLiked
    
    ReplySortSelectionView(selectedReplySortOption: $selected)
}
