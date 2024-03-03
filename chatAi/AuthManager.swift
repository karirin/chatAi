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
    @Published var userProf: [String] = []
    @Published var userPreFlag: Int = 0
    @Published var avatars: [Avatar] = []
    @Published var backgrounds: [Background] = []
    @Published var usedBackgroundName: String = ""
    @Published var usedAvatarName: String = ""
    @Published var usedAvatarSystem: String = ""
    @Published var usedAvatarHeart: Int = 0
    
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
    
    func fetchUserProf() {
        // ユーザーIDの存在を確認
        guard let userId = user?.uid else { return }
        
        // データベースの参照を設定
        let userRef = Database.database().reference().child("users").child(userId)
        
        // 単一イベントの監視を開始
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            // スナップショットからデータを取得し、String型の配列としてキャスト
            if let data = snapshot.value as? [String: Any],
               let userProfs = data["userProf"] as? [String] {
                // userProfs配列を扱う処理
                print("userProfs: \(userProfs)")
                
                // 例えば、userProfsをクラスのプロパティに格納するなど
                self.userProf = userProfs
            }
        }
    }
    
    func fetchPreFlag() {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                self.userPreFlag = data["userPreFlag"] as? Int ?? 0
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
    
    func switchBackground(to newAvatar: Background, completion: @escaping (Bool) -> Void) {
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
    
    func fetchUsedAvatars(completion: @escaping ([Avatar]) -> Void) {
        print("fetchUsedAvatars @@@@@")
        guard let userId = user?.uid else {
            completion([]) // ユーザーIDがない場合は空の配列を返す
            return
        }
        print("fetchUsedAvatars2 @@@@@")
        let userRef = Database.database().reference().child("users").child(userId).child("avatars")
        userRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            var usedAvatars: [Avatar] = []
            let group = DispatchGroup() // アバターのsystem情報を非同期で取得するためのグループ
            
            print("fetchUsedAvatars4 @@@@@@@")
            for child in snapshot.children {
                print("fetchUsedAvatars5 @@@@@@@:\(child)")
                if let childSnapshot = child as? DataSnapshot,
                   let avatarData = childSnapshot.value as? [String: Any],
                   let name = avatarData["name"] as? String,
                   let heart = avatarData["heart"] as? Int,
                   let attack = avatarData["attack"] as? Int,
                   let health = avatarData["health"] as? Int,
                   let usedFlag = avatarData["usedFlag"] as? Int,
                   let count = avatarData["count"] as? Int,
                   let systemKey = avatarData["systemKey"] as? String, // systemIdを参照
                   
                   usedFlag == 1 { // usedFlagが1のアバターのみをフィルタリング
                    group.enter() // 非同期処理の開始を通知
                    let systemRef = Database.database().reference().child("avatarSystems").child(systemKey)
                    print("fetchUsedAvatars7 @@@@@@@:\(systemRef)")
                    systemRef.observeSingleEvent(of: .value) { systemSnapshot in
                        if let systemData = systemSnapshot.value as? [String: Any],
                           let systemDescription = systemData["description"] as? String {
                            print("fetchUsedAvatars9 @@@@@@@:\(systemDescription)")
                            self!.usedAvatarSystem = systemDescription
                            let avatar = Avatar(name: name, systemKey: systemDescription, heart: heart, attack: attack, health: health, usedFlag: usedFlag, count: count)
                            print("fetchUsedAvatars10 @@@@@@@:\(avatar)")
                            self!.usedAvatarName = avatar.name
                            self!.usedAvatarHeart = avatar.heart
                            usedAvatars.append(avatar)
                        } else {
                            print("System description not found or is not a string")
                        }
                        group.leave() // 非同期処理の終了を通知
                    }
                }
            }

            group.notify(queue: .main) {
                completion(usedAvatars) // すべての非同期処理が完了したらメインスレッドでコールバックを実行
            }
        }
    }


    
//    func fetchUsedAvatars(completion: @escaping ([Avatar]) -> Void) {
//        guard let userId = user?.uid else {
//            completion([]) // ユーザーIDがない場合は空の配列を返す
//            return
//        }
//        let userRef = Database.database().reference().child("users").child(userId).child("avatars")
//        userRef.observeSingleEvent(of: .value) { snapshot in
//            var usedAvatars: [Avatar] = []
//            for child in snapshot.children {
//                if let childSnapshot = child as? DataSnapshot,
//                   let avatarData = childSnapshot.value as? [String: Any],
//                   let name = avatarData["name"] as? String,
//                   let system = avatarData["system"] as? String,
//                   let heart = avatarData["heart"] as? Int,
//                   let attack = avatarData["attack"] as? Int,
//                   let health = avatarData["health"] as? Int,
//                   let usedFlag = avatarData["usedFlag"] as? Int,
//                   let count = avatarData["count"] as? Int,
//                   usedFlag == 1 { // usedFlagが1のアバターのみをフィルタリング
//                    let avatar = Avatar(name: name, system: system, heart: heart, attack: attack, health: health, usedFlag: usedFlag, count: count)
//                    usedAvatars.append(avatar)
//                    self.usedAvatarSystem = avatar.system
//                    self.usedAvatarName = avatar.name
//                    self.usedAvatarHeart = avatar.heart
//                    print("self.usedAvatarHeart:\(self.usedAvatarHeart)")
//                }
//            }
//            DispatchQueue.main.async {
//                completion(usedAvatars) // メインスレッドでコールバックを実行
//            }
//        }
//    }

    
    func fetchAvatars(completion: @escaping () -> Void) {
        guard let userId = user?.uid else { return }
        let userRef = Database.database().reference().child("users").child(userId).child("avatars")
        userRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            var newAvatars: [Avatar] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let avatarData = childSnapshot.value as? [String: Any],
                   let name = avatarData["name"] as? String,
                   let systemKey = avatarData["systemKey"] as? String,
                   let heart = avatarData["heart"] as? Int,
                   let attack = avatarData["attack"] as? Int,
                   let health = avatarData["health"] as? Int,
                   let usedFlag = avatarData["usedFlag"] as? Int,
                   let count = avatarData["count"] as? Int {
                    let avatar = Avatar(name: name,systemKey: systemKey,heart: heart, attack: attack, health: health, usedFlag: usedFlag, count: count)
                    newAvatars.append(avatar)
                }
            }
            DispatchQueue.main.async {
                self.avatars = newAvatars
            }

            completion() // データがフェッチされた後にクロージャを呼び出す
        }
    }
    
    func fetchBackgrounds(completion: @escaping () -> Void) {
        guard let userId = user?.uid else { return }
        let userRef = Database.database().reference().child("users").child(userId).child("backgrounds")
        userRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            var newBackgrounds: [Background] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let backgroundData = childSnapshot.value as? [String: Any],
                   let name = backgroundData["name"] as? String,
                   let usedFlag = backgroundData["usedFlag"] as? Int{
                    let background = Background(name: name,usedFlag: usedFlag)
                    newBackgrounds.append(background)
                }
            }
            DispatchQueue.main.async {
                self.backgrounds = newBackgrounds
                print("self.backgrounds:\(self.backgrounds)")
            }

            completion() // データがフェッチされた後にクロージャを呼び出す
        }
    }
    
    func decreaseUserCoinCount(by amount: Int = 1, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        
        // 現在のuserMoneyを取得
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                var currentCoinCount = data["coinCount"] as? Int ?? 0
                
                // userMoneyからamountを引く
                currentCoinCount -= amount
                
                // 新しいuserMoneyの値をデータベースに保存
                let userData: [String: Any] = ["coinCount": currentCoinCount]
                userRef.updateChildValues(userData) { (error, ref) in
                    if let error = error {
                        print("Failed to update userMoney:", error.localizedDescription)
                        completion(false)
                    } else {
                        print("Successfully updated userMoney.")
                        completion(true)
                    }
                }
            }
        }
    }
    
    func decreaseUserMoney(by amount: Int = 100, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        
        // 現在のuserMoneyを取得
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                var currentMoney = data["userMoney"] as? Int ?? 0
                
                // userMoneyからamountを引く
                currentMoney -= amount
                
                // 新しいuserMoneyの値をデータベースに保存
                let userData: [String: Any] = ["userMoney": currentMoney]
                userRef.updateChildValues(userData) { (error, ref) in
                    if let error = error {
                        print("Failed to update userMoney:", error.localizedDescription)
                        completion(false)
                    } else {
                        print("Successfully updated userMoney.")
                        completion(true)
                    }
                }
            }
        }
    }
    
    func fetchUsedBackgrounds(completion: @escaping ([Background]) -> Void) {
        guard let userId = user?.uid else {
            completion([]) // ユーザーIDがnilの場合は空の配列を返す
            return
        }

        let backgroundsRef = Database.database().reference().child("users").child(userId).child("backgrounds")
        backgroundsRef.observeSingleEvent(of: .value) { snapshot in
            var usedBackgrounds: [Background] = []
            
            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot,
                      let backgroundData = childSnapshot.value as? [String: Any],
                      let name = backgroundData["name"] as? String,
                      let usedFlag = backgroundData["usedFlag"] as? Int,
                      usedFlag == 1 else {
                    continue
                }

                // usedFlagが1のBackgroundを作成して配列に追加
                let background = Background(name: name, usedFlag: usedFlag)
                print("background:\(background)")
                usedBackgrounds.append(background)
                self.usedBackgroundName = background.name
            }

            DispatchQueue.main.async {
                completion(usedBackgrounds) // usedFlagが1のbackgroundsを返す
            }
        }
    }
    
    func updateUserNameAndHobbies(userId: String, newName: String, newHobbies: [String], completion: @escaping (Bool, Error?) -> Void) {
        // ユーザーIDに基づいてデータベース内のユーザー参照を取得
        let userRef = Database.database().reference().child("users").child(userId)

        // 新しい名前と趣味を設定するための辞書を作成
        let updates = ["userName": newName, "userProf": newHobbies] as [String : Any]

        // ユーザー名と趣味を更新
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                // エラーがある場合は、completionハンドラーをfalseと共に呼び出す
                completion(false, error)
            } else {
                // 更新が成功した場合は、completionハンドラーをtrueと共に呼び出す
                completion(true, nil)
            }
        }
    }

    
    func fetchUserInfo(completion: @escaping (String?, [[String: Any]]?, Int?, Int?, Int?, Int?, Int?) -> Void) {
        guard let userId = user?.uid else {
            completion(nil, nil, nil, nil, nil, nil, nil)
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
               let tutorialNum = data["tutorialNum"] as? Int,
               let userFlag = data["userFlag"] as? Int{  // 追加

                var filteredAvatars: [[String: Any]] = []
                for (_, avatarData) in avatarsData {
                    if avatarData["usedFlag"] as? Int == 1 {
                        filteredAvatars.append(avatarData)
                    }
                }
                completion(userName, filteredAvatars, userMoney, userHp, userAttack, tutorialNum, userFlag)  // 追加
            } else {
                completion(nil, nil, nil, nil, nil, nil, nil)  // 追加
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
    
    func loadRecentMessages(userId: String, completion: @escaping ([ChatMessage]) -> Void) {
        let ref = Database.database().reference().child("messages").child(userId)

        ref.queryOrdered(byChild: "timestamp").queryLimited(toLast: 50).observeSingleEvent(of: .value) { snapshot in
            var recentMessages: [ChatMessage] = []

            // DataSnapshotの配列として安全に取得する
            var snapshots: [DataSnapshot] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    snapshots.append(snapshot)
                }
            }
            snapshots = snapshots.reversed() // 配列を逆順にする

            print("loadRecentMessages1")
            for snapshot in snapshots {
                if let value = snapshot.value as? [String: Any],
                   let content = value["content"] as? String,
                   let roleString = value["role"] as? String,
                   roleString == "user" { // ロールが"user"のメッセージのみをフィルタリング
                    let role = ChatRole(rawValue: roleString) ?? .user
                    let message = ChatMessage(role: role, content: content)
                    recentMessages.append(message)
                    if recentMessages.count == 10 { // 直近の10件の"user"メッセージを取得したらループを抜ける
                        break
                    }
                }
            }

            completion(recentMessages)
        }
    }




    
    func saveLastLoginDate(userId: String, completion: @escaping (Bool) -> Void) {
        let ref = Database.database().reference().child("users").child(userId)
        let timestamp = Date().timeIntervalSince1970 // 現在のタイムスタンプを取得
        ref.updateChildValues(["lastLoginDate": timestamp]) { (error, _) in
            completion(error == nil)
        }
    }
    
//    func updateCoinCountBasedOnLastLogin(userId: String) {
//        let ref = Database.database().reference().child("users").child(userId)
//        ref.observeSingleEvent(of: .value) { snapshot in
//            guard let value = snapshot.value as? [String: AnyObject],
//                  let lastLoginTimestamp = value["lastLoginDate"] as? TimeInterval else {
//                return
//            }
//            let lastLoginDate = Date(timeIntervalSince1970: lastLoginTimestamp)
//            let currentTime = Date()
//            let elapsedTime = currentTime.timeIntervalSince(lastLoginDate)
//            let seconds = elapsedTime // 経過時間を秒単位で計算
//
//            let newCoinCount: Int
//            if seconds < 10 {
//                newCoinCount = 0 // 10秒未満ならば更新しない
//            } else {
//                // 10秒ごとにコインを加算するロジック
//                // 例: 経過時間が10秒以上ならば、10秒毎に1コインを追加し、最大で3コインまで加算可能
//                newCoinCount = min(Int(seconds / 10), 3) // 最大3まで
//            }
//
//            // coinCountを更新
//            if newCoinCount > 0 {
//                ref.updateChildValues(["coinCount": newCoinCount]) { (error, _) in
//                    if let error = error {
//                        print("Error updating coin count: \(error.localizedDescription)")
//                    } else {
//                        print("Successfully updated coin count to \(newCoinCount)")
//                    }
//                }
//            }
//        }
//    }
    
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
            let minutes = elapsedTime / 60 // 経過時間を分単位で計算

            let newCoinCount: Int
            if minutes < 10 {
                newCoinCount = 0 // 10分未満ならば更新しない
            } else {
                // 10分ごとにコインを加算するロジックを追加
                // 例: 経過時間が10分以上ならば、10分毎に1コインを追加し、最大で6コインまで加算可能
                newCoinCount = min(Int(minutes / 10), 3) // 1時間につき最大5まで
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

    
//    func updateCoinCountBasedOnLastLogin(userId: String) {
//        let ref = Database.database().reference().child("users").child(userId)
//        ref.observeSingleEvent(of: .value) { snapshot in
//            guard let value = snapshot.value as? [String: AnyObject],
//                  let lastLoginTimestamp = value["lastLoginDate"] as? TimeInterval else {
//                return
//            }
//            let lastLoginDate = Date(timeIntervalSince1970: lastLoginTimestamp)
//            let currentTime = Date()
//            let elapsedTime = currentTime.timeIntervalSince(lastLoginDate)
//            let hours = elapsedTime / 3600 // 経過時間を時間単位で計算
//
//            let newCoinCount: Int
//            if hours < 1 {
//                newCoinCount = 0 // 1時間未満ならば更新しない
//            } else {
//                newCoinCount = min(Int(hours), 3) // 最大で3まで
//            }
//
//            // coinCountを更新
//            if newCoinCount > 0 {
//                ref.updateChildValues(["coinCount": newCoinCount]) { (error, _) in
//                    if let error = error {
//                        print("Error updating coin count: \(error.localizedDescription)")
//                    } else {
//                        print("Successfully updated coin count to \(newCoinCount)")
//                    }
//                }
//            }
//        }
//    }
    
    func saveTreasureForUser(userId: String, treasure: String) {
        let TreasureRef = Database.database().reference().child("treasures").child(userId)
        // 辞書形式でデータを追加する
        let TreasureData = [treasure: true] // または任意の値
        TreasureRef.updateChildValues(TreasureData) { error, ref in
            if let error = error {
                print("Error saving title: \(error)")
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
    
    func updateTutorialNum(userId: String, tutorialNum: Int, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["tutorialNum": tutorialNum]
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                print("Error updating tutorialNum: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func updateContact(userId: String, newContact: String, completion: @escaping (Bool) -> Void) {
        // contactテーブルの下の指定されたuserIdの参照を取得
        let contactRef = Database.database().reference().child("contacts").child(userId)
        
        // まず現在のcontactの値を読み取る
        contactRef.observeSingleEvent(of: .value, with: { snapshot in
            // 既存の問い合わせ内容を保持する変数を準備
            var contacts: [String] = []
            
            // 現在の問い合わせ内容がある場合、それを読み込む
            if let currentContacts = snapshot.value as? [String] {
                contacts = currentContacts
            }
            
            // 新しい問い合わせ内容をリストに追加
            contacts.append(newContact)
            
            // データベースを更新する
            contactRef.setValue(contacts, withCompletionBlock: { error, _ in
                if let error = error {
                    print("Error updating contact: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            })
        }) { error in
            print(error.localizedDescription)
            completion(false)
        }
    }

    func updateUserFlag(userId: String, userFlag: Int, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["userFlag": userFlag]
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                print("Error updating tutorialNum: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func updatePreFlag(userId: String, userPreFlag: Int, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["userPreFlag": userPreFlag]
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func deleteUserAccount(completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.removeValue { error, _ in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }

    
    func saveUserToDatabase(userName: String,userProf: [String], completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        let userData: [String: Any] = ["userName": userName, "userProf": userProf, "userMoney": 10, "userHp": 100, "userAttack": 20, "tutorialNum": 0, "userFlag": 1, "coinCount": 3]
        
        userRef.setValue(userData) { (error, ref) in
            if let error = error {
                print("Failed to save user to database:", error.localizedDescription)
                return
            }
            print("Successfully saved user to database.")
        }
        completion(true)
    }
    
    func addBackgroundToUser(backgroundName: String, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false) // user IDがnilの場合、失敗としてfalseを返す
            return
        }

        // ユーザーの背景データの参照を作成
        let backgroundsRef = Database.database().reference()
            .child("users")
            .child(userId)
            .child("backgrounds")

        // すべての背景を取得
        backgroundsRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                var backgroundExists = false

                // 各背景をループして、新しい背景が既存のものと一致するか確認
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    if let backgroundData = child.value as? [String: Any],
                       let name = backgroundData["name"] as? String,
                       name == backgroundName {
                        backgroundExists = true
                        break
                    }
                }

                if !backgroundExists {
                    // 新しい背景をデータベースに追加
                    let newBackgroundRef = backgroundsRef.childByAutoId()
                    let backgroundDict: [String: Any] = ["name": backgroundName, "usedFlag": 0] // usedFlagを1に設定
                    newBackgroundRef.setValue(backgroundDict) { error, _ in
                        if let error = error {
                            print("Failed to add background to database:", error.localizedDescription)
                            completion(false)
                        } else {
                            print("Successfully added background to database.")
                            completion(true)
                        }
                    }
                } else {
                    // 背景が既に存在する場合の処理
                    completion(false)
                }
            } else {
                // スナップショットが存在しない場合、即座に背景を追加
                let newBackgroundRef = backgroundsRef.childByAutoId()
                let backgroundDict: [String: Any] = ["name": backgroundName, "usedFlag": 1] // usedFlagを1に設定
                newBackgroundRef.setValue(backgroundDict) { error, _ in
                    if let error = error {
                        print("Failed to add background to database:", error.localizedDescription)
                        completion(false)
                    } else {
                        print("Successfully added background to database.")
                        completion(true)
                    }
                }
            }
        }
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
                    "systemKey": avatar.systemKey,
                    "heart": avatar.heart,
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
    
    func addCoinAvatarToUser(avatar: Avatar, completion: @escaping (Bool) -> Void) {
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
                    "systemKey": avatar.systemKey,
                    "heart": avatar.heart,
                    "health": avatar.health,
                    "usedFlag": 0,
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
