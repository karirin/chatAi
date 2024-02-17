//
//  AuthManager.swift
//  chatAi
//
//  Created by Apple on 2024/02/16.
//

import SwiftUI
import Firebase
import OpenAIKit

class AuthManager: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var money: Int = 0
    @Published var coinCount: Int = 0
    
    var onLoginCompleted: (() -> Void)?
    var currentUserId: String? {
        print("user?.uid:\(user?.uid)")
        return user?.uid
    }
    
    init() {
        user = Auth.auth().currentUser
        if user == nil {
            anonymousSignIn()
        }
    }
    
    static let shared: AuthManager = {
        let instance = AuthManager()
        return instance
    }()
    
    func fetchCoinCount() {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                self.coinCount = data["coinCount"] as? Int ?? 0
            }
        }
    }
    
    func addMoney(amount: Int) {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        
        // 現在の所持金を取得
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                let currentMoney = data["userMoney"] as? Int ?? 0
                
                // 新しく獲得するお金を加える
                let newMoney = currentMoney + amount
                
                self.money = newMoney
                
                // 更新された所持金をデータベースに保存
                let userData: [String: Any] = ["userMoney": self.money]
                userRef.updateChildValues(userData)
            }
        }
    }
    
    func saveMessage(userId: String, message: ChatMessage) {
        let ref = Database.database().reference().child("messages").childByAutoId() // メッセージのための新しいIDを生成
        let messageData: [String: Any] = [
            "userId": userId,
            "content": message.content,
            "role": message.role.rawValue,
            "timestamp": ServerValue.timestamp() // Firebaseのサーバータイムスタンプを使用
        ]

        ref.setValue(messageData) { error, _ in
            if let error = error {
                print("Error saving message: \(error.localizedDescription)")
            } else {
                print("Successfully saved message")
            }
        }
    }

//    func loadMessages(completion: @escaping ([ChatMessage]) -> Void) {
//        let ref = Database.database().reference().child("messages")
//        ref.observe(.value) { snapshot in
//            var messages: [ChatMessage] = []
//            
//            for child in snapshot.children {
//                if let snapshot = child as? DataSnapshot,
//                   let value = snapshot.value as? [String: Any],
//                   let userId = value["userId"] as? String,
//                   let content = value["content"] as? String,
//                   let roleString = value["role"] as? String,
//                   let role = ChatMessage.Role(rawValue: roleString) {
//                    let message = ChatMessage(role: role, content: content)
//                    messages.append(message)
//                }
//            }
//            
//            completion(messages)
//        }
//    }

    
    func saveLastLoginDate(userId: String, completion: @escaping (Bool) -> Void) {
        let ref = Database.database().reference().child("users").child(userId)
        let timestamp = Date().timeIntervalSince1970 // 現在のタイムスタンプを取得
        ref.updateChildValues(["lastLoginDate": timestamp]) { (error, _) in
            completion(error == nil)
        }
    }
    
    func updateCoinCountBasedOnLastLogin(userId: String) {
        let ref = Database.database().reference().child("users").child(userId)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: AnyObject],
                  let lastLoginTimestamp = value["lastLoginDate"] as? TimeInterval else {
                return
            }
            let lastLoginDate = Date(timeIntervalSince1970: lastLoginTimestamp)
            let currentTime = Date()
            let elapsedTime = currentTime.timeIntervalSince(lastLoginDate)
            let hours = elapsedTime / 3600 // 経過時間を時間単位で計算

            let newCoinCount: Int
            if hours < 1 {
                newCoinCount = 0 // 1時間未満ならば更新しない
            } else {
                newCoinCount = min(Int(hours), 3) // 最大で3まで
            }

            // coinCountを更新
            if newCoinCount > 0 {
                ref.updateChildValues(["coinCount": newCoinCount]) { (error, _) in
                    if let error = error {
                        print("Error updating coin count: \(error.localizedDescription)")
                    } else {
                        print("Successfully updated coin count to \(newCoinCount)")
                    }
                }
            }
        }
    }
    
    func fetchLastLoginDate(userId: String, completion: @escaping (Date?) -> Void) {
        let ref = Database.database().reference().child("users").child(userId)
        ref.child("lastLoginDate").observeSingleEvent(of: .value) { (snapshot) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            if let dateString = snapshot.value as? String, let date = dateFormatter.date(from: dateString) {
                completion(date)
            } else {
                completion(nil)
            }
        }
    }
    
    func saveUserToDatabase(userName: String, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        let userData: [String: Any] = ["userName": userName, "userMoney": 0, "userHp": 100, "userAttack": 20, "tutorialNum": 1, "userFlag": 0]
        
        userRef.setValue(userData) { (error, ref) in
            if let error = error {
                print("Failed to save user to database:", error.localizedDescription)
                return
            }
            print("Successfully saved user to database.")
        }
        completion(true)
    }
    
    func addAvatarToUser(avatar: Avatar, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false) // user IDがnilの場合、失敗としてfalseを返す
            return
        }

        // ユーザーのアバターデータの参照を作成
        let avatarsRef = Database.database().reference()
            .child("users")
            .child(userId)
            .child("avatars")

        // すべてのアバターを取得
        avatarsRef.observeSingleEvent(of: .value) { (snapshot, error) in
            if let error = error {
                print("Error fetching avatars: \(error)")
                completion(false) // エラーが発生した場合、falseを返す
                return
            }
            
            var avatarExists = false
            var existingRef: DatabaseReference?

            // 各アバターをループして、新しいアバターが既存のものと一致するか確認
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let avatarData = childSnapshot.value as? [String: Any],
                   let name = avatarData["name"] as? String,
                   name == avatar.name {
                    avatarExists = true
                    existingRef = childSnapshot.ref
                    break
                }
            }

            if avatarExists, let existingRef = existingRef {
                existingRef.child("count").runTransactionBlock { currentData in
                    var count = currentData.value as? Int ?? 0
                    count += 1
                    currentData.value = count
                    return TransactionResult.success(withValue: currentData)
                }
                completion(true) // トランザクションが完了した場合、trueを返す
            } else {
                // 新しいアバターをデータベースに追加
                let avatarRef = avatarsRef.childByAutoId()
                let avatarData: [String: Any] = [
                    "name": avatar.name,
                    "attack": avatar.attack,
                    "health": avatar.health,
                    "usedFlag": avatar.usedFlag,
                    "count": 1  // 初期カウント値を設定
                ]
                avatarRef.setValue(avatarData) { (error, ref) in
                    if let error = error {
                        print("Failed to add avatar to database:", error.localizedDescription)
                        completion(false) // 保存に失敗した場合、falseを返す
                        return
                    }
                    print("Successfully added avatar to database.")
                    completion(true) // 保存に成功した場合、trueを返す
                }
            }
        }
    }
    
    func anonymousSignIn() {
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let result = result {
                print("Signed in anonymously with user ID: \(result.user.uid)")
                self.user = result.user
                self.onLoginCompleted?()
            }
        }
    }
}

struct AuthManager1: View {
    @ObservedObject var authManager = AuthManager.shared

    var body: some View {
        VStack {
            if authManager.user == nil {
                Text("Not logged in")
            } else {
                Text("Logged in with user ID: \(authManager.user!.uid)")
            }
            Button(action: {
                if self.authManager.user == nil {
                    self.authManager.anonymousSignIn()
                }
            }) {
                Text("Log in anonymously")
            }
        }
    }
}

struct AuthManager_Previews: PreviewProvider {
    static var previews: some View {
        AuthManager1()
    }
}
