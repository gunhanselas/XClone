//
//  ProfileContentFilterView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/31/25.
//

import SwiftUI

struct ProfileContentFilterView: View {
    @Binding var selectedTab: Int
    @Namespace private var animation

    var body: some View {
        HStack {
            ForEach(ProfileContentFilterModel.allCases) { filter in
                VStack {
                    Text(filter.description)
                        .font(.subheadline)
                        .fontWeight(selectedTab == filter.rawValue ? .semibold : .regular)
                        .foregroundColor(selectedTab == filter.rawValue ? .black : .gray)
                        .onTapGesture { selectedTab = filter.rawValue }
                    
                    if selectedTab == filter.rawValue {
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
        .animation(.smooth, value: selectedTab)
        .padding(.top)
    }
}

#Preview {
    @Previewable @State var selectedTab = 0
    
    ProfileContentFilterView(selectedTab: $selectedTab)
}
