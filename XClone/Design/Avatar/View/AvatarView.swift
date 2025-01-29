//
//  AvatarView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import Kingfisher
import SwiftUI

struct AvatarView: View {
    private let user: User?
    private let image: Image?
    private let size: AvatarSize
    
    init(user: User?, size: AvatarSize) {
        self.user = user
        self.size = size
        
        self.image = nil
    }
    
    init(image: Image?, size: AvatarSize) {
        self.image = image
        self.size = size
        
        self.user = nil
    }
    
    var body: some View {
        if let imageUrl = user?.profileImageUrl {
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
        } else if let image = image {
            image
                .resizable()
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
                .foregroundStyle(Color(.systemGray5), .gray)
        }
    }
}

#Preview {
    AvatarView(user: MockData.currentUser, size: .medium)
}
