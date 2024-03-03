//
//  SignUp.swift
//  chatAi
//
//  Created by Apple on 2024/02/16.
//

import SwiftUI

struct Avatar: Equatable {
    var name: String
    var systemKey: String
    var heart: Int
    var attack: Int
    var health: Int
    var usedFlag: Int
    var count: Int
}

struct SignUp: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var userName: String = "a"
    @State private var showImagePicker: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                    HStack{
                    Text("ユーザー名を入力してください")
                            .font(.system(size: 26))
                            .fontWeight(.bold)
                    }
                Text("10文字以下で入力してください")
                            .font(.system(size: 18))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top,5)
                    HStack {
                        Spacer()
                        ZStack(alignment: .trailing) {
                TextField("名前", text: $userName)
                        .onChange(of: userName) { newValue in
                            if newValue.count > 10 {
                                userName = String(newValue.prefix(10))
                            }
                        }
                                .font(.system(size: 30))
                                .padding(.trailing, userName.isEmpty ? 0 : 40)
                            if !userName.isEmpty {
                                                   Button(action: {
                                                       self.userName = ""
                                                   }) {
                                                       Image(systemName: "xmark.circle.fill")
                                                           .foregroundColor(.gray)
                                                   }
                                                   .font(.system(size: 30))
                                                   .padding(.trailing, 5) // バツ印の位置を調整
                                               }
                                           }
                        .padding()
                                Spacer() // this will push the TextField to the center
                        Spacer()
                                                }
                    .padding()
                Text("\(userName.count) / 10")
                       .font(.system(size: 30))
                                       .font(.caption)
                                       .foregroundColor(.secondary)
                                       .padding(.bottom)
                NavigationLink(destination: UserDetailView(userName: $userName).navigationBarBackButtonHidden(true), isActive: $showImagePicker) {
                    Button(action: {
                        self.showImagePicker = true
                    }) {
                        ZStack {
                            // ボタンの背景
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white)
                                .frame(width: 140, height: 70)
                                .shadow(radius: 3) // ここで影をつけます
                            Text("次へ")
                        }
                    }
                    
                    .font(.system(size:26))
                    .foregroundColor(Color.gray)
                    .background(RoundedRectangle(cornerRadius: 25)
                        .fill(userName.isEmpty ? Color.gray : Color.white))
                    .opacity(userName.isEmpty ? 0.5 : 1.0)
                }.disabled(userName.isEmpty)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct HobbyButton: View {
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

struct UserDetailView: View {
    // 趣味の選択肢
    let hobbies = ["食事","映画鑑賞","読書","ショッピング","旅行","スポーツ","ゲーム","アウトドア","ファッション","アニメ","漫画","ペット・動物","アート・文化","お笑い","エステ"]
       
       // 選択された趣味を追跡するための状態
       @State private var selectedHobbies = Set<String>()
    @Binding var userName: String
    @State private var showImagePicker: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
            // スクロール可能なビュー
                // 縦方向のスタック
                VStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.black)
                            Text("戻る")
                                .foregroundColor(.black)
                                .font(.body)
                            Spacer()
                        }
                        .padding(.leading)
                    }
                    Spacer()
                        Text("趣味・興味があるもの")
                            .font(.system(size: 26))
                            .fontWeight(.bold)
                        Text("趣味・興味があるものを選択してください。\n※入力は任意です")
                            .font(.system(size: 16))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal,5)
                            .padding(.top,5)
                        // 趣味のグリッド表示
                        let columns = [
                            GridItem(.adaptive(minimum: 100))
                        ]
                        
                        LazyVGrid(columns: columns, spacing: 30) {
                            ForEach(hobbies, id: \.self) { hobby in
                                HobbyButton(hobby: hobby, isSelected: selectedHobbies.contains(hobby)) {
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
                        .padding(.horizontal,10)
                        NavigationLink(destination: ImagePickerView(userName: $userName, selectedHobbies: Array(selectedHobbies)).navigationBarBackButtonHidden(true), isActive: $showImagePicker) {
                            Button(action: {
                                self.showImagePicker = true
                                
                                print("selectedHobbies:\(Array(selectedHobbies))")
                            }) {
                                ZStack {
                                    // ボタンの背景
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.white)
                                        .frame(width: 140, height: 70)
                                        .shadow(radius: 3) // ここで影をつけます
                                    Text("次へ")
                                }
                            }
                            
                            .font(.system(size:26))
                            .foregroundColor(Color.gray)
                            .background(RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white))
                            .opacity(1.0)
                        }
                    Spacer()
                
            
        }
    }
}

struct ImagePickerView: View {
    @Binding var userName: String
    var selectedHobbies: [String]
    @State private var avator: UIImage?
    @State private var isImagePickerDisplay = false
    @ObservedObject private var authManager = AuthManager.shared
    @State private var showProfileCreation: Bool = false // 追加
    @State private var selectedIcon: String = "ハムたむ"
    @State private var showingIconPicker = false
    let defaultImage = UIImage(named: "defaultProfileImage")
    @State private var selectedAvatar: Avatar? // 選択したアバターを保持するプロパティ
    let avatars = [
        Avatar(name: "ハムたむ",systemKey: "system1", heart: 0, attack: 10, health: 20, usedFlag: 1, count: 1),
        Avatar(name: "アプル君",systemKey: "system2", heart: 0, attack: 15, health: 15, usedFlag: 1, count: 1),
        Avatar(name: "ライム",systemKey: "system3", heart: 0, attack: 20, health: 10, usedFlag: 1, count: 1)
    ]
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToContentView: Bool = false

    var body: some View {
        NavigationView{
            VStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.black)
                        Text("戻る")
                            .foregroundColor(.black)
                            .font(.body)
                        Spacer()
                    }
                    .padding(.leading)
                }
                Spacer()
                HStack{
                    Text("会話するおともを選択してください")
                            .font(.system(size:22))
                }
                Spacer()
                if let selected = selectedAvatar {
                    VStack {
                        Text(selected.name)
                            .font(.system(size:24))
                            .fontWeight(.bold)
                            .foregroundColor(Color.gray)
                        Image(selected.name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 180)
                            .cornerRadius(15)
                    }
                }
                Spacer()
                    HStack() {
                        ForEach(avatars, id: \.name) { avatar in
                            Button(action: {
                                self.selectedAvatar = avatar
                            }) {
                                Image(avatar.name)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .padding(10)
                                    .border(Color.blue, width: selectedAvatar?.name == avatar.name ? 2 : 0)
                            }
                        }
                    }
                Spacer()
                Button(action: {
                    var selectedAvatar = Avatar(name: self.selectedAvatar?.name ?? "ハムたむ", systemKey: self.selectedAvatar!.systemKey,heart: 0, attack: 20, health: 20 ,usedFlag: 1, count:1)
                    authManager.saveUserToDatabase(userName: userName,userProf: selectedHobbies) { success in
                        if success {
                            authManager.addAvatarToUser(avatar: selectedAvatar) { success in
                                if success {
                                    print(selectedAvatar)
                                    
                                    authManager.addBackgroundToUser(backgroundName: "背景1") { success in
                                        if success {
                                            print("背景が正常に追加されました。")
                                        } else {
                                            print("背景の追加に失敗しました。")
                                        }
                                    }
                                    self.navigateToContentView = true
                                } else {
                                    // アバターの追加に失敗した場合の処理をここに書く
                                }
                            }
                        } else {
                            // ユーザー情報の保存に失敗した場合の処理をここに書く
                        }
                    }
                }) {
                    ZStack {
                    // ボタンの背景
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                        .frame(width: 300, height: 70)
                        .shadow(radius: 3) // ここで影をつけます
                    Text("ユーザーを作成")
                        .shadow(radius: 0)
                }
                    }
                    .padding(.vertical,20)
                    .padding(.horizontal,35)
                    .font(.system(size:26))
                    .foregroundColor(Color("fontGray"))
                    .background(RoundedRectangle(cornerRadius: 25)
                        .fill(.white))
                    .padding()
                
            Spacer()
                }
            
                .background(
                    NavigationLink("", destination: TopView().navigationBarBackButtonHidden(true), isActive: $navigateToContentView)
                        .hidden() // NavigationLinkを非表示にする
                )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear{
            self.selectedAvatar = avatars[0]
        }
        .navigationBarBackButtonHidden(true)
        
       
    }
}

struct SignUp_Previews: PreviewProvider {
    @State static var userName: String = "りょうや" // ここでダミーのユーザー名を設定
    @State static var defaultImage = UIImage(named: "defaultProfileImage")

    static var previews: some View {
         SignUp()
//        UserDetailView(userName: .constant(userName))
        
    }
}
