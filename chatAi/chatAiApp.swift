//
//  chatAiApp.swift
//  chatAi
//
//  Created by Apple on 2024/02/15.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseMessaging
import UserNotifications


//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    
//
//    return true
//  }
//}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
//        FirebaseApp.configure()

        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })

        application.registerForRemoteNotifications()

        Messaging.messaging().token { token, error in
            if let error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token {
                print("FCM registration token: \(token)")
            }
        }

        return true
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Oh no! Failed to register for remote notifications with error \(error)")
    }

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var readableToken = ""
        for index in 0 ..< deviceToken.count {
            readableToken += String(format: "%02.2hhx", deviceToken[index] as CVarArg)
        }
        print("Received an APNs device token: \(readableToken)")
    }
}

extension AppDelegate: MessagingDelegate {
    @objc func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase token: \(String(describing: fcmToken))")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.banner, .list, .sound]])
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(
            name: Notification.Name("didReceiveRemoteNotification"),
            object: nil,
            userInfo: userInfo
        )
        completionHandler()
    }
}

@main
struct chatAiApp: App {
    
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State static private var showExperienceModalPreview = false
    @State private var isUserExists: Bool? = nil
    @State private var isLoading: Bool = false
    @ObservedObject var appState = AppState()
    
    init() {
        FirebaseApp.configure()
        AppState()
    }

  var body: some Scene {
    WindowGroup {
      NavigationView {
//        ContentView()
//          SignUp()
//          Chat()
          if isUserExists == nil{
//          if isLoading == true {
              // ユーザー存在チェック中の表示 (例: ローディングインジケータ)
              ActivityIndicator()
          } else if isUserExists == false || isUserExists == nil {
              SignUp()
          } else {
              //                ContentView(isPresentingQuizBeginnerList: .constant(false), isPresentingAvatarList: .constant(false))
              //                ContentView()
              TopView()
          }
      }
      .navigationViewStyle(StackNavigationViewStyle())
      .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
              print("appState.isBannerVisible:\(appState.isBannerVisible)")
//              isLoading = false
              if appState.isBannerVisible {
                  AuthManager.shared.updatePreFlag(userId: AuthManager.shared.currentUserId!, userPreFlag: 0){ success in
                  }
              }
          }
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
