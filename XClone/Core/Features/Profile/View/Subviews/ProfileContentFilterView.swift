//
//  ProfileContentFilterView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/31/25.
//

import SwiftUI

struct ProfileContentFilterView: View {
    @Binding var selectedFilter: ProfileContentFilterModel
    @Namespace private var animation

    var body: some View {
        HStack {
            ForEach(ProfileContentFilterModel.allCases) { filter in
                VStack {
                    Text(filter.description)
                        .font(.subheadline)
                        .fontWeight(selectedFilter == filter ? .semibold : .regular)
                        .foregroundColor(selectedFilter == filter ? .primaryText : .gray)
                        .onTapGesture { selectedFilter = filter }
                    
                    if selectedFilter == filter {
                        Rectangle()
                            .frame(height: 3)
                            .matchedGeometryEffect(id: "underline", in: animation)
                            .foregroundColor(.blue)
                    } else {
                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(.clear)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
        .animation(.smooth, value: selectedFilter)
    }
}

#Preview {
    @Previewable @State var selectedFilter: ProfileContentFilterModel = .posts
    
    ProfileContentFilterView(selectedFilter: $selectedFilter)
}
