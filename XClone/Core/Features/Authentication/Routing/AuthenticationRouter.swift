//
//  AuthenticationRouter.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import Observation

@Observable
class AuthenticationRouter {
    var path = [AuthenticationRoutes]()
    
    func startAccountCreationFlow() {
        guard let firstStep = AccountCreationRoutes(rawValue: 0) else { return }
        path.append(.accountCreation(firstStep))
    }
    
    func showLogin() {
        path.removeAll()
        path.append(.login(.loginView))
    }
    
    func showUsernameViewAfterGoogleAuth() {
        path.append(.googleAuthentication(.usernameView))
    }
    
    func pushNextAccountCreationStep() {
        guard let currentStep = path.last,
              case .accountCreation(let accountCreationRoutes) = currentStep else {
            print("No valid account creation step found.")
            return
        }

        switch accountCreationRoutes {
        case .userInformationView:
            path.append(.accountCreation(.passwordView))
        case .passwordView:
            path.append(.accountCreation(.profilePhotoSelectionView))
        case .profilePhotoSelectionView:
            path.append(.accountCreation(.profileHeaderPhotoSelectionView))
        case .profileHeaderPhotoSelectionView:
            print("DEBUG: Complete flow..")
        }
    }
}
