//
//  AddUsernameView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/28/25.
//

import SwiftUI

struct AddUsernameView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    
    @State private var usernameValidationState: InputValidationState = .idle
    @State private var validationManager = RegistrationValidationManager(service: RegistrationValidationService())
    @State private var username = ""
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("To get started, pick a username")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Your @username is unique, you can always change it later.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            FormInputField(
                "Enter username",
                validationState: usernameValidationState,
                errorMessage: "This username is unavailable, please try again",
                text: $username
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            
            Spacer()
            
            XButton("Next") {
                validateUsername()
            }
            .buttonStyle(.standard)
            .disabled(!formIsValid || usernameValidationState == .validating || usernameValidationState == .invalid)
            .opacity(formIsValid ? 1.0 : 0.5)
        }
        .navigationBarBackButtonHidden()
        .padding()
    }
}

private extension AddUsernameView {
    var formIsValid: Bool {
        return username.isValidUsername()
    }
    
    func validateUsername() {
        Task {
            usernameValidationState = .validating
            let validationState = await validationManager.validateUsername(username)
            
            if validationState == .validated {
                usernameValidationState = .validated
                try await userManager.uploadUsername(username)
                authManager.updateAuthState(.authenticated)
            } else {
                usernameValidationState = .invalid
            }
        }
    }
}

#Preview {
    AddUsernameView()
}
