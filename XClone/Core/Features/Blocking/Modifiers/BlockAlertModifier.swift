//
//  BlockAlertModifier.swift
//  XClone
//
//  Created by Stephan Dowless on 2/27/25.
//

import SwiftUI

struct BlockAlertModifier: ViewModifier {
    @Binding var isShowingBlockAlert: Bool

    let user: User?
    let onBlock: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert("Block @\(user?.username ?? "user")", isPresented: $isShowingBlockAlert, actions: {
                Button("Block", role: .destructive) {
                    onBlock()
                }
                
                Button("Cancel", role: .cancel) {}
            }, message: {
                Text("They will be able to see your public posts, but will no longer be able to engage with them. They will also not be able to follow or message you, and you will not see notifications from them.")
            })
    }
}
