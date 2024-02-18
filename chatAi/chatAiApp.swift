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
    

    return true
  }
}

@main
struct chatAiApp: App {
    
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State static private var showExperienceModalPreview = false
    @State private var isUserExists: Bool? = nil
    
    init() {
        FirebaseApp.configure()
    }

  var body: some Scene {
    WindowGroup {
      NavigationView {
//        ContentView()
//          SignUp()
//          Chat()
         if isUserExists == false || isUserExists == nil {
              SignUp()
          } else {
              //                ContentView(isPresentingQuizBeginnerList: .constant(false), isPresentingAvatarList: .constant(false))
              //                ContentView()
              TopView()
          }
      }.onAppear {
          if let userId = AuthManager.shared.currentUserId {
              AuthManager.shared.checkIfUserIdExists(userId: userId) { exists in
                  self.isUserExists = exists
              }
          } else {
              self.isUserExists = false
          }
      }
    }
  }
}
