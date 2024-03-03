//
//  NameUpdateView.swift
//  chatAi
//
//  Created by Apple on 2024/02/25.
//

import SwiftUI

struct NameUpdateView: View {
    let hobbies = ["食事","映画鑑賞","読書","ショッピング","旅行","スポーツ","ゲーム","アウトドア","ファッション","アニメ","漫画","ペット・動物","アート・文化","お笑い","エステ"]
    @ObservedObject var audioManager:AudioManager
    @ObservedObject var authManager = AuthManager.shared
    @StateObject var store: Store = Store()
    @State var toggle = false
    @State private var userName: String = ""
    @State private var showAlert = false
    @State private var avatar: [[String: Any]] = []
    @State private var userMoney: Int = 0
    @State private var userLevel: Int = 0
    @State private var userHp: Int = 100
    @State private var userFlag: Int = 0
    @State private var userAttack: Int = 20
    @State private var tutorialNum: Int = 0
    @State private var selectedHobbies = Set<String>()
    
    var body: some View {
        VStack {
            HStack{
                Spacer()
                Text("プロフィールを編集する")
                    .font(.system(size:24))
                Spacer()
            }
            VStack(alignment: .center){
                HStack {
                    Text("")
                        .frame(width:10,height:20)
                        .background(Color("fontGray"))
                    Text("名前を変更する")
                        .font(.system(size: 20))
                    Spacer()
                }
                TextField("名前", text: $userName)
                    .onChange(of: userName) { newValue in
                        if newValue.count > 10 {
                            userName = String(newValue.prefix(10))
                        }
                    }
                    .padding(5)
                    .padding(.leading)
                    .background(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                Text("\(userName.count) / 10")
                    .font(.system(size: 20))
                    .font(.caption)
                // スクロール可能なビュー
                // 縦方向のスタック
                VStack{
                    HStack {
                        Text("")
                            .frame(width:10,height:20)
                            .background(Color("fontGray"))
                        Text("趣味・興味があるものを変更する")
                            .font(.system(size: 20))
                        Spacer()
                    }
                        // 趣味のグリッド表示
                        let columns = [
                            GridItem(.adaptive(minimum: 100)),
                            GridItem(.adaptive(minimum: 100)),
                            GridItem(.adaptive(minimum: 100))
                        ]

                        
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(hobbies, id: \.self) { hobby in
                                HobbyUpdateButton(hobby: hobby, isSelected: selectedHobbies.contains(hobby)) {
                                    // 趣味選択のトグル
                                    if selectedHobbies.contains(hobby) {
                                        selectedHobbies.remove(hobby)
                                    } else {
                                        selectedHobbies.insert(hobby)
                                    }
                                }
                            }
                        }
                        .padding()
                        .padding(.horizontal,-10)
                    }
                    Button(action: {
                        // selectedHobbiesをArrayに変換
                           let hobbiesArray = Array(selectedHobbies)
                           // ユーザー名と趣味を更新する
                           authManager.updateUserNameAndHobbies(userId: authManager.currentUserId!, newName: userName, newHobbies: hobbiesArray) { success, error in
                               if success {
                                   showAlert = true
                                   print("ユーザー名と趣味が更新されました。")
                               } else if let error = error {
                                   print("ユーザー名と趣味の更新に失敗しました: \(error.localizedDescription)")
                               }
                           }
                    }, label: {
                        Text("変更する")
                            .fontWeight(.semibold)
                            .frame(width: 130, height:40)
                            .foregroundColor(Color.white)
                            .background(Color.gray)
                            .cornerRadius(24)
                    })
                    .shadow(radius: 3)
                    .padding(.top,5)
                    .padding(.bottom,10)
                     .opacity(userName.isEmpty ? 0.5 : 1.0)
                     .disabled(userName.isEmpty)
                }
                Spacer()
            }
        .onAppear {
            authManager.fetchUserProf()
            selectedHobbies = Set(authManager.userProf)
        }
            .alert(isPresented: $showAlert) { // アラートを表示する
                Alert(
                    title: Text(""),
                    message: Text("ユーザー名が変更されました"),
                    dismissButton: .default(Text("OK")) {
                    }
                )
            }
            .frame(maxWidth: .infinity,maxHeight:.infinity)
            .foregroundColor(Color("fontGray"))
            .padding()
        .background(Color("background"))
        .foregroundColor(Color("fontGray"))
                .onAppear{
                    
                        authManager.fetchUserInfo { (name, avatar, money, hp, attack, tutorialNum, userFlag) in
                                        self.userName = name ?? ""
                                        self.avatar = avatar ?? [[String: Any]]()
                                        self.userMoney = money ?? 0
                                        self.userHp = hp ?? 100
                                        self.userAttack = attack ?? 20
                                        self.tutorialNum = tutorialNum ?? 0
                                        self.userFlag = userFlag ?? 0
                                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print(store.productList)
                    }
                }
            //            .padding(50)
          
        }
//    }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
    }

struct HobbyUpdateButton: View {
    var hobby: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(hobby)
                .padding(8)
                .frame(width:100)
                .font(.system(size: 13))
                .foregroundColor(isSelected ? .white : .black)
                // ここで`background`に角丸の形を直接指定します。
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color("hpMonsterColor") : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.white : Color.gray, lineWidth: 1)
                )
        }
    }
}

#Preview {
    NameUpdateView(audioManager: AudioManager())
}
