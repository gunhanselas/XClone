//
//  XCloneApp.swift
//  XClone
//
//  Created by Stephan Dowless on 1/23/25.
//

import FirebaseCore
import GoogleSignIn
import SwiftUI

@main
struct XCloneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State private var authManager = AuthManager()
    @State private var userManager = UserManager(service: UserService())
    
    init() {
        loadRocketSimConnect()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environment(userManager)
        }
    }
}

private extension XCloneApp {
    private func loadRocketSimConnect() {
        #if DEBUG
        guard Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() == true else {
            print("Failed to load linker framework")
            return
        }
        print("DEBUG: RocketSim Connect successfully linked")
        #endif
    }
}
