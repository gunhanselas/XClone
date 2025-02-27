//
//  View+BlockAlert.swift
//  XClone
//
//  Created by Stephan Dowless on 2/27/25.
//

import SwiftUI

extension View {
    func blockAlert(user: User?, isShowing: Binding<Bool>, onBlock: @escaping () -> Void) -> some View {
        modifier(BlockAlertModifier(isShowingBlockAlert: isShowing, user: user, onBlock: onBlock))
    }
}
