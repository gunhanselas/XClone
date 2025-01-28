//
//  FormInputField.swift
//  XClone
//
//  Created by Stephan Dowless on 1/27/25.
//

import SwiftUI

struct FormInputField: View {
    @Binding private var text: String
    
    private let titleKey: String
    private let validationState: InputValidationState
    private let errorMessage: String?
    private let isSecureField: Bool
    
    init(
        _ titleKey: String,
        validationState: InputValidationState = .idle,
        errorMessage: String? = nil,
        isSecureField: Bool = false,
        text: Binding<String>
    ) {
        _text = text
        
        self.titleKey = titleKey
        self.validationState = validationState
        self.errorMessage = errorMessage
        self.isSecureField = isSecureField
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            VStack(alignment: .leading) {
                if !text.isEmpty {
                    Text(titleKey)
                        .foregroundStyle(.primary.opacity(0.87))
                        .font(.footnote)
                }
                
                HStack {
                    Group {
                        if isSecureField {
                            SecureField(titleKey, text: $text)
                        } else {
                            TextField(titleKey, text: $text)
                        }
                    }
                    .font(.subheadline)
                    .padding(.vertical, 8)

                    Spacer()
                    
                    switch validationState {
                    case .idle:
                        EmptyView()
                    case .validating:
                        ProgressView()
                    case .invalid:
                        Image(systemName: "exclamationmark.circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(.red)
                    case .validated:
                        Image(systemName: "checkmark.circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(.green)
                    }
                }
                
                Divider()
                
                if validationState == .invalid, let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

#Preview {
    VStack {
        FormInputField("Name", text: .constant(""))
        
        FormInputField("Name", validationState: .validating, text: .constant(""))
        FormInputField("Name", validationState: .invalid, text: .constant(""))
        FormInputField("Name", validationState: .validated, text: .constant(""))
    }
}
