//
//  AuthenticationRoutes.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import SwiftUI

enum LoginRoutes: Int, Hashable {
    case loginView
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .loginView:
            LoginView()
        }
    }
}

enum AccountCreationRoutes: Int, Hashable {
    case userInformationView
    case passwordView
    case profilePhotoSelectionView
    case profileHeaderPhotoSelectionView
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .userInformationView:
            UserInformationView()
        case .passwordView:
            CreatePasswordView()
        case .profilePhotoSelectionView:
            ProfileImageSelectorView()
        case .profileHeaderPhotoSelectionView:
            ProfileHeaderImageSelectorView()
        }
    }
}

enum GoogleAuthenticationRoutes: Int, Hashable {
    case usernameView
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .usernameView:
            AddUsernameView()
        }
    }
}

enum AuthenticationRoutes: Hashable {
    case login(LoginRoutes)
    case accountCreation(AccountCreationRoutes)
    case googleAuthentication(GoogleAuthenticationRoutes)
}
