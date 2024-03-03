//
//  AvatarListView.swift
//  it
//
//  Created by hashimo ryoya on 2023/09/26.
//

import SwiftUI
import Firebase

struct AvatarListView: View {
    let items = ["もりこう","ライム", "レッドドラゴン", "レインボードラゴン"]
    
    enum ActiveAlert: Identifiable {
        case alert1
        case alert2
        case coinError

        var id: Int {
            switch self {
            case .alert1:
                return 1
            case .alert2:
                return 2
            case .coinError:
                return 3
            }
        }
    }

    
    struct Item: Identifiable {
        let name: String  // これが一意の識別子として機能します
        let attack: Int
        let heart: Int
        let probability: Int
        let health: Int
        var id: String { name }  // Identifiable の要件を満たすために name を id として使用
    }
    
    let allItems: [Avatar] = [
        Avatar(name: "ハムたむ",systemKey: "system1", heart: 0, attack: 10, health: 20, usedFlag: 1, count: 1),
       Avatar(name: "アプル君",systemKey: "system2", heart: 0, attack: 15, health: 15, usedFlag: 1, count: 1),
       Avatar(name: "ライム",systemKey: "system3", heart: 0, attack: 20, health: 10, usedFlag: 1, count: 1)
    ]
    
    @State private var selectedItem: Avatar?
    @State private var avatars: [String] = []
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioManager = AudioManager.shared
    // アラートを表示するかどうかを制御するState変数
    @State private var showingAlert1 = false
    @State private var showingAlert2 = false
    // 切り替えるアバターを保持するState変数
    @State private var switchingAvatar: Avatar?
    @State private var showingCoinErrorAlert = false
    @State private var activeAlert: ActiveAlert?
    @State private var usedAvatar: Avatar?
    @State private var changeFlag = false
    @State private var userName: String = ""
    @State private var avatar: [[String: Any]] = []
    @State private var userMoney: Int = 0
    @State private var tutorialNum: Int = 0
    @State private var userLevel: Int = 0
    @State private var userHp: Int = 100
    @State private var userFlag: Int = 0
    @State private var userAttack: Int = 20
    
    // グリッドのレイアウトを定義
    var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {
            if authManager.avatars.isEmpty {
                ActivityIndicator()
            }else{
                HStack{
                    Spacer()
                    ZStack{
                        Image("コインバー")
                            .resizable()
                            .frame(width:90,height:40)
                        Text("\(authManager.money)")
                            .foregroundStyle(Color("fontGray"))
                            .font(.system(size: 18))
                            .padding(.leading,40)
                    }
                    .padding(.trailing)
                }
                // 選択されたアイテムを大きく表示
                if let selected = selectedItem {
                    if authManager.avatars.contains(where: { $0.name == selected.name }) {
                        VStack {
                            Text(selected.name)
                                .font(.system(size:24))
                                .fontWeight(.bold)
                                .foregroundColor(Color.gray)
                            ZStack{
                                Image(selected.name)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 180)
                                    .cornerRadius(15)
                                if selected.name == authManager.usedAvatarName {
                                    Image("選択中")
                                        .resizable()
                                        .frame(width: 70, height: 30)
                                        .position(x: UIScreen.main.bounds.width / 1.3, y: UIScreen.main.bounds.height / 4.7)
                                } else {
                                    Button(action: {
                                        audioManager.playSound()
                                        self.switchingAvatar = selected
                                        activeAlert = .alert1
                                    }) {
                                        Image("切り替え")
                                            .resizable()
                                            .frame(width: 80, height: 40)
                                            .position(x: UIScreen.main.bounds.width / 1.3, y: UIScreen.main.bounds.height / 21.0)
                                    }
                                }
                            }
                            .frame(height:180)
                            HStack{
                                Image("ハート")
                                    .resizable()
                                    .frame(width: 20,height:20)
                                Text("\(selected.heart)")
                                    .font(.system(size:24))
                                    .foregroundColor(Color("fontGray"))
                            }
                        }
                    }else{
                        ZStack{
                            Button(action: {
                                audioManager.playSound()
                                self.switchingAvatar = selected
                                activeAlert = .alert2
                            }) {
                                
                                VStack {
                                    Text("???")
                                        .font(.system(size:24))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.gray)
                                    Image("\(selected.name)_シルエット")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 180)
                                        .cornerRadius(15)
                                        .frame(height:180)
                                }
                            }
                        }
                        Spacer()
                            .frame(height:53)
                    }
                }
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(allItems, id: \.name) { avatar in
                            VStack{
                                ZStack{
                                    if authManager.avatars.contains(where: { $0.name == avatar.name }) {
                                        Button(action: {
                                            // ここにおともを切り替えるコードを書く
                                            self.switchingAvatar = avatar
                                            if selectedItem == avatar {
                                                // 2回目のタップでアラートを表示
                                                self.switchingAvatar = avatar
                                                activeAlert = .alert1
                                            }
                                            selectedItem = avatar
                                            audioManager.playSound()
                                        }) {
                                            Image(avatar.name) // avatarのnameを使用
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 100, height: 100)
                                                .padding(5)
                                                .cornerRadius(8)
                                        }
                                    } else {
                                        Button(action: {
                                            // ここにおともを切り替えるコードを書く
                                            self.switchingAvatar = avatar
                                            if selectedItem == avatar {
                                                // 2回目のタップでアラートを表示
                                                self.switchingAvatar = avatar
                                                self.activeAlert = .alert2
                                            }
                                            selectedItem = avatar
                                            audioManager.playSound()
                                        }) {
                                            Image("\(avatar.name)_シルエット")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 100, height: 100)
                                                .padding(5)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke((selectedItem?.name == avatar.name) ? Color.gray : Color.clear, lineWidth: 4)
                                )
                            }
                            .alert(item: $activeAlert) { alertType in
                                switch alertType {
                                case .alert1:
                                    return Alert(
                                        title: Text("おともを切り替えますか？"),
                                        primaryButton: .default(Text("はい"), action: {
                                            // はいを選択した場合、usedFlagを更新
                                            if let switchingAvatar = switchingAvatar {
                                                authManager.switchAvatar(to: switchingAvatar) { success in
                                                    if success {
                                                        changeFlag = true
                                                        print("Avatar successfully added!")
                                                    } else {
                                                        print("Failed to add avatar.")
                                                    }
                                                }
                                            }
                                            audioManager.playChangeSound()
                                        }),
                                        secondaryButton: .cancel(Text("キャンセル"))
                                    )
                                case .alert2:
                                    return Alert(
                                        title: Text("100コインでおともを解放しますか？"),
                                        primaryButton: .default(Text("はい"), action: {
                                            // はいを選択した場合、usedFlagを更新
                                            if authManager.money >= 100 {
                                                authManager.decreaseUserMoney { success in
                                                    if success {
                                                        authManager.addCoinAvatarToUser(avatar: switchingAvatar!) { success in
                                                            if success {
                                                                
                                                            } else {
                                                            }
                                                        }
                                                    } else {
                                                    }
                                                }
                                                audioManager.playChangeSound()
                                            }else{
                                                // コインが足りない場合、エラーアラートを表示
                                                self.activeAlert = .coinError
                                            }
                                        }),
                                        secondaryButton: .cancel(Text("キャンセル"))
                                    )
                                case .coinError:
                                    return Alert(
                                        title: Text("エラー"),
                                        message: Text("コインが足りません。"),
                                        dismissButton: .default(Text("OK"))
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            
        }
        .background(Color("background"))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            audioManager.playCancelSound()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.gray)
            Text("戻る")
                .foregroundColor(Color("fontGray"))
        })
        .frame(maxWidth:.infinity,maxHeight:.infinity)
        .onReceive(authManager.$avatars) { newAvatars in
            // avatarsが更新されたときに呼ばれる
            if let updatedAvatar = newAvatars.first(where: { $0.usedFlag == 1 }) {
                //                            print(updatedAvatar)
                self.selectedItem = updatedAvatar
            }
        }
        .onChange(of: changeFlag) { _ in
            authManager.fetchUsedAvatars { usedAvatars in
                self.usedAvatar = usedAvatars.first { $0.usedFlag == 1 }
                print("onChange:\(self.usedAvatar)")
                changeFlag = false
            }
        }
        .onAppear {
            authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum, userFlag) in
                self.userName = name ?? ""
                self.avatar = avatar ?? [[String: Any]]()
                self.userMoney = money ?? 0
                self.userHp = hp ?? 100
                self.userAttack = attack ?? 20
                self.tutorialNum = tutorialNum ?? 0
                self.userFlag = userFlag ?? 0
            }
            authManager.fetchUsedAvatars(){ avatars in
                for avatar in avatars {
                    usedAvatar = avatar
                }
            }
            authManager.fetchAvatars {
                if let defaultAvatar = authManager.avatars.first(where: { $0.usedFlag == 1 }) {
                    self.selectedItem = defaultAvatar
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                authManager.fetchAvatars {
                    //                        print(authManager.avatars.heart)
                    for item in allItems {
                        let contains = authManager.avatars.contains(where: { $0.name == item.name })
                    }
                }
            }
        }
    }
}

struct OtomoListView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarListView()
    }
}
