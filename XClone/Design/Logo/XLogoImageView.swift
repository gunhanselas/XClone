//
//  XLogoImageView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/28/25.
//

import SwiftUI

struct XLogoImageView: View {
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        Image(scheme == .dark ? .xLogoWhite: .xLogo)
            .resizable()
            .frame(width: 140, height: 100)
    }
}

#Preview {
    XLogoImageView()
}
