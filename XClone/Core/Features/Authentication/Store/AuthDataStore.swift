//
//  AuthDataStore.swift
//  XClone
//
//  Created by Stephan Dowless on 1/29/25.
//

import SwiftUI

class AuthDataStore: ObservableObject {
    @Published var email = ""
    @Published var username = ""
    @Published var name = ""
    @Published var password = ""
    @Published var profileImage: Image? 
}
