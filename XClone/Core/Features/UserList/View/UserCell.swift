//
//  UserCell.swift
//  XClone
//
//  Created by Stephan Dowless on 2/6/25.
//

import SwiftUI

struct UserCell: View {
    private let user: User
    private let accessoryAction: (() -> Void)?
    private let accessoryButtonTitle: String?
    
    init(user: User) {
        self.user = user
        self.accessoryAction = nil
        self.accessoryButtonTitle = nil
    }
    
    init(user: User, accessoryButtonTitle: String, accessoryAction: @escaping () -> Void) {
        self.user = user
        self.accessoryAction = accessoryAction
        self.accessoryButtonTitle = accessoryButtonTitle
    }
    
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
            
            if let accessoryButtonTitle, let accessoryAction {
                XButton(accessoryButtonTitle, action: accessoryAction)
                    .buttonStyle(.standard(size: .compact))
            }
        }
        .foregroundStyle(.primaryText)
        .padding(.horizontal)
    }
}
