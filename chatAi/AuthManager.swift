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
    @Published var level: Int = 0
    @Published var coinCount: Int = 0
    @Published var avatars: [Avatar] = []
    
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
    
    func checkIfUserIdExists(userId: String, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
        }
    }
    
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
        let ref = Database.database().reference().child("messages").child(userId).childByAutoId() // メッセージのための新しいIDを生成
        let messageData: [String: Any] = [
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
    
    func switchAvatar(to newAvatar: Avatar, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false) // user IDがnilなので、失敗としてfalseを返します。
            return
        }
        
        let avatarsRef = Database.database().reference()
            .child("users")
            .child(userId)
            .child("avatars")
        
        avatarsRef.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot else { continue }
                let avatarKey = childSnapshot.key
                let avatarRef = avatarsRef.child(avatarKey)
                avatarRef.updateChildValues(["usedFlag": 0])
            }
            
            if let avatarKey = snapshot.children.allObjects.first(where: { (child) -> Bool in
                guard let childSnapshot = child as? DataSnapshot,
                      let avatarData = childSnapshot.value as? [String: Any],
                      let name = avatarData["name"] as? String else { return false }
                return name == newAvatar.name
            }) as? DataSnapshot {
                let avatarRef = avatarsRef.child(avatarKey.key)
                avatarRef.updateChildValues(["usedFlag": 1]) { (error, ref) in
                    if let error = error {
                        print("Failed to update avatar: \(error.localizedDescription)")
                        completion(false) // 更新に失敗したので、falseを返します。
                    } else {
                        print("Successfully updated avatar.")
                        self.fetchAvatars {
                            completion(true) // 更新に成功したので、trueを返します。
                        }
                    }
                }
            } else {
                completion(false) // 新しいアバターが見つからなかったので、falseを返します。
            }
        }
    }
    
    func switchBackground(to newAvatar: Avatar, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false) // user IDがnilなので、失敗としてfalseを返します。
            return
        }
        
        let backgroundsRef = Database.database().reference()
            .child("users")
            .child(userId)
            .child("backgrounds")
        
        backgroundsRef.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot else { continue }
                let backgroundKey = childSnapshot.key
                let backgroundsRef = backgroundsRef.child(backgroundKey)
                backgroundsRef.updateChildValues(["usedFlag": 0])
            }
            
            if let backgroundKey = snapshot.children.allObjects.first(where: { (child) -> Bool in
                guard let childSnapshot = child as? DataSnapshot,
                      let backgroundData = childSnapshot.value as? [String: Any],
                      let name = backgroundData["name"] as? String else { return false }
                return name == newAvatar.name
            }) as? DataSnapshot {
                let backgroundRef = backgroundsRef.child(backgroundKey.key)
                backgroundRef.updateChildValues(["usedFlag": 1]) { (error, ref) in
                    if let error = error {
                        print("Failed to update avatar: \(error.localizedDescription)")
                        completion(false) // 更新に失敗したので、falseを返します。
                    } else {
                        print("Successfully updated avatar.")
                        self.fetchAvatars {
                            completion(true) // 更新に成功したので、trueを返します。
                        }
                    }
                }
            } else {
                completion(false) // 新しいアバターが見つからなかったので、falseを返します。
            }
        }
    }
    
    func addHeartToAvatar(userId: String, additionalHeart: Int, completion: @escaping (Bool) -> Void) {
           let avatarsRef = Database.database().reference().child("users").child(userId).child("avatars")
           avatarsRef.observeSingleEvent(of: .value) { snapshot in
               var updated = false
               
               // 各アバターをループして、usedFlagが1のアバターを見つける
               for child in snapshot.children {
                   if let childSnapshot = child as? DataSnapshot,
                      let avatarData = childSnapshot.value as? [String: Any],
                      let usedFlag = avatarData["usedFlag"] as? Int,
                      usedFlag == 1 {
                       var newHeart = avatarData["heart"] as? Int ?? 0
                       newHeart += additionalHeart // heartに値を加算
                       
                       // 更新されたheartの値をデータベースに保存
                       childSnapshot.ref.updateChildValues(["heart": newHeart]) { error, _ in
                           if let error = error {
                               print("Failed to update avatar's heart: \(error.localizedDescription)")
                           } else {
                               print("Successfully updated avatar's heart.")
                               updated = true
                           }
                       }
                       break
                   }
               }
               
               completion(updated)
           }
       }
    
    func fetchAvatars(completion: @escaping () -> Void) {
        guard let userId = user?.uid else { return }
        let userRef = Database.database().reference().child("users").child(userId).child("avatars")
        userRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            var newAvatars: [Avatar] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let avatarData = childSnapshot.value as? [String: Any],
                   let name = avatarData["name"] as? String,
                   let heart = avatarData["heart"] as? Int,
                   let attack = avatarData["attack"] as? Int,
                   let health = avatarData["health"] as? Int,
                   let usedFlag = avatarData["usedFlag"] as? Int,
                   let count = avatarData["count"] as? Int {
                    let avatar = Avatar(name: name,heart: heart, attack: attack, health: health, usedFlag: usedFlag, count: count)
                    newAvatars.append(avatar)
                }
            }
            DispatchQueue.main.async {
                self.avatars = newAvatars
            }

            completion() // データがフェッチされた後にクロージャを呼び出す
        }
    }
    
    func fetchUserInfo(completion: @escaping (String?, [[String: Any]]?, Int?, Int?, Int?, Int?) -> Void) {
        guard let userId = user?.uid else {
            completion(nil, nil, nil, nil, nil, nil)
            return
        }
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any],
               let userName = data["userName"] as? String,
               let avatarsData = data["avatars"] as? [String:[String: Any]],
               let userMoney = data["userMoney"] as? Int,
               let userHp = data["userHp"] as? Int,
               let userAttack = data["userAttack"] as? Int,
               let tutorialNum = data["tutorialNum"] as? Int {  // 追加

                var filteredAvatars: [[String: Any]] = []
                for (_, avatarData) in avatarsData {
                    if avatarData["usedFlag"] as? Int == 1 {
                        filteredAvatars.append(avatarData)
                    }
                }
                completion(userName, filteredAvatars, userMoney, userHp, userAttack, tutorialNum)  // 追加
            } else {
                completion(nil, nil, nil, nil, nil, nil)  // 追加
            }
        }
    }

    func loadMessages(userId: String, completion: @escaping ([ChatMessage]) -> Void) {
        let ref = Database.database().reference().child("messages").child(userId)
        ref.observe(.value) { snapshot in
            var messages: [ChatMessage] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let value = snapshot.value as? [String: Any],
                   let content = value["content"] as? String,
                   let roleString = value["role"] as? String {
                   let role = ChatRole(rawValue: roleString) ?? .user
                   let message = ChatMessage(role: role, content: content)
                   messages.append(message)
                }
            }
            
            completion(messages)
        }
    }

    
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
