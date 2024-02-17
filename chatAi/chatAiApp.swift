//
//  chatAiApp.swift
//  chatAi
//
//  Created by Apple on 2024/02/15.
//

import SwiftUI
import Firebase


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      if let userId = Auth.auth().currentUser?.uid {
          AuthManager.shared.updateCoinCountBasedOnLastLogin(userId: userId)
      }

    return true
  }
}

@main
struct chatAiApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
//          Chat()
      }
    }
  }
}
