//
//  AuthDataStore.swift
//  XClone
//
//  Created by Stephan Dowless on 1/29/25.
//

import Foundation

class AuthDataStore: ObservableObject {
    @Published var email = ""
    @Published var username = ""
    @Published var name = ""
    @Published var password = ""
}
