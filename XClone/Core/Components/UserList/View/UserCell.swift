//
//  UserCell.swift
//  XClone
//
//  Created by Stephan Dowless on 2/6/25.
//

import SwiftUI

struct UserCell: View {
    let user: User
    
    var body: some View {
        HStack {
            AvatarView(user: user, size: .xSmall)
            
            VStack(alignment: .leading) {
                Text(user.username)
                    .fontWeight(.semibold)
                
                if let fullname = user.fullname {
                    Text(fullname)
                }
            }
            .font(.footnote)
            
            Spacer()
        }
        .foregroundStyle(.primaryText)
        .padding(.horizontal)
    }
}
