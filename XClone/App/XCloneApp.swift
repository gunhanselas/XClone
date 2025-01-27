//
//  XCloneApp.swift
//  XClone
//
//  Created by Stephan Dowless on 1/23/25.
//

import FirebaseCore
import SwiftUI

@main
struct XCloneApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
