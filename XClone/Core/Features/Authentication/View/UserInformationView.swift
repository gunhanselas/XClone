//
//  RegistrationView.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import SwiftUI

struct UserInformationView: View {
    @Environment(AuthenticationRouter.self) private var router
    
    @State private var name = ""
    @State private var email = ""
    @State private var username = ""
    
    @State private var validationManager = RegistrationValidationManager(service: RegistrationValidationService())
    @State private var emailValidation: InputValidationState = .idle
    @State private var usernameValidation: InputValidationState = .idle
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                Text("Create your account")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 20) {
                    FormInputField("Name", text: $name)
                        .textContentType(.name)
                    
                    FormInputField(
                        "Email address",
                        validationState: emailValidation,
                        errorMessage: "This email is not valid. Please try again.",
                        text: $email
                    )
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    
                    FormInputField(
                        "Username",
                        validationState: usernameValidation,
                        errorMessage: "This username is not valid. Please try again.",
                        text: $username
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                }
                .padding(.vertical)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            XButton("Next") {
                router.pushNextAccountCreationStep()
            }
            .buttonStyle(.standard(size: .compact))
//            .disabled(!formIsValid)
//            .opacity(formIsValid ? 1.0 : 0.5)
        }
        .onChange(of: username) { _, newValue in
            validateUsername(newValue)
        }
        .onChange(of: email) { _, newValue in
            validateEmail(newValue)
        }
        .padding()
    }
}

private extension UserInformationView {
    var formIsValid: Bool {
        return name.isValidName() &&
        emailValidation == .validated &&
        usernameValidation == .validated
    }
    
    func validateEmail(_ email: String) {
        guard email.isValidEmail() else {
            emailValidation = .idle
            return
        }
        
        Task {
            emailValidation = .validating
            try await Task.sleep(for: .seconds(1))
            emailValidation = .validated
        }
    }
    
    func validateUsername(_ username: String) {
        guard username.isValidUsername() else {
            usernameValidation = .idle
            return
        }
        
        Task {
            usernameValidation = .validating
            try await Task.sleep(for: .seconds(1))
            usernameValidation = .validated
        }
    }
}

#Preview {
    UserInformationView()
}
