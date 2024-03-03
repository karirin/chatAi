//
//  IllustratedView.swift
//  it
//
//  Created by hashimo ryoya on 2023/11/07.
//

import SwiftUI
import Firebase

struct Background: Equatable {
    let name: String  // これが一意の識別子として機能します
    var usedFlag: Int
}

struct BackgroundView: View {
    let items = ["もりこう","ライム", "レッドドラゴン", "レインボードラゴン"]
    
    struct Item: Identifiable {
        let name: String  // これが一意の識別子として機能します
        let imageName: String
        let condition: String
        let attack: Int
        let probability: Int
        let health: Int
        let rarity: Rarity
        var id: String { name }  // Identifiable の要件を満たすために name を id として使用
    }

    enum Rarity {
        case normal
        case rare
        case superRare
        case ultraRare
        case legendRare
        
        var displayString: String {
            switch self {
            case .normal:
                return "ノーマル" // 任意の文字列を返す
            case .rare:
                return "レア"
            case .superRare:
                return "スーパーレア"
            case .ultraRare:
                return "ウルトラレア"
            case .legendRare:
                return "レジェンドレア"
            }
        }
    }
    
    let allItems: [Item] = [
        Item(name: "背景1", imageName: "お部屋", condition: "", attack: 10, probability: 25,health: 20, rarity: .normal),
        Item(name: "背景2", imageName: "大草原", condition: "親密度が300以上だと解放されます", attack: 15, probability: 25,health: 15, rarity: .normal),
        Item(name: "背景3", imageName: "海中", condition: "親密度が500以上だと解放されます", attack: 20, probability: 25, health: 10, rarity: .normal),
        Item(name: "背景4", imageName: "洞窟", condition: "親密度が800以上だと解放されます", attack: 20, probability: 25, health: 100, rarity: .normal),
        Item(name: "背景5", imageName: "宇宙", condition: "親密度が1000以上だと解放されます", attack: 20, probability: 25, health: 100, rarity: .normal)
    ]
    
    @State private var selectedItem: Item?
    @State private var usedBackground: Background?
    @State private var backgrounds: [String] = []
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioManager = AudioManager.shared
    // アラートを表示するかどうかを制御するState変数
    @State private var showingAlert1 = false
    @State private var showingAlert2 = false
    @State private var changeFlag = false
    // 切り替えるアバターを保持するState変数
    @State private var switchingBackground: Item?
    @State private var previouslySelectedItemName: String? = nil
    
    // グリッドのレイアウトを定義
    var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        
        VStack {
            if authManager.backgrounds.isEmpty {
                ActivityIndicator()
            } else {
                // 選択されたアイテムを大きく表示
                if let selected = selectedItem {
                    if authManager.backgrounds.contains(where: { $0.name == selected.name }) {
                        Text(selected.imageName)
                            .font(.system(size:24))
                            .fontWeight(.bold)
                            .foregroundColor(Color.gray)
                        ZStack{
                            
                            Image(selected.name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 180)
                                .cornerRadius(15)
                            if usedBackground!.name == selected.name {
                                VStack{
                                    Spacer()
                                        .frame(height:100)
                                    HStack{
                                        Spacer()
                                            .frame(width:200)
                                        Image("選択中")
                                            .resizable()
                                            .frame(width: 70, height: 30)
                                    }
                                }
                            } else {
                                VStack{
                                    Spacer()
                                        .frame(height:100)
                                    HStack{
                                        Spacer()
                                            .frame(width:200)
                                        Button(action: {
                                            audioManager.playSound()
                                            self.switchingBackground = selected
                                            self.showingAlert1 = true
                                        }) {
                                            Image("切り替え")
                                                .resizable()
                                                .frame(width: 70, height: 30)
                                        }
                                        .alert(isPresented: $showingAlert1) {
                                            Alert(
                                                title: Text("エリアを切り替えますか？"),
                                                primaryButton: .default(Text("はい"), action: {
                                                    // はいを選択した場合、usedFlagを更新
                                                    if let switchingBackground = switchingBackground {
                                                        authManager.switchBackground(to: Background(name: switchingBackground.name, usedFlag: 1)) { success in
                                                            if success {
                                                                print("Avatar successfully added!")
                                                                self.changeFlag = true
                                                            } else {
                                                                print("Failed to add avatar.")
                                                            }
                                                        }
                                                    }
                                                    changeFlag = true
                                                    audioManager.playChangeSound()
                                                }),
                                                secondaryButton: .cancel(Text("キャンセル"))
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        Spacer()
                            .frame(height:50)
                    }else{
                        ZStack{
                            Image("\(selected.rarity.displayString)")
                                .resizable()
                                .frame(width: 70,height:70)
                                .padding(.trailing,240)
                                .padding(.bottom,100)
                            VStack {
                                Text("???")
                                    .font(.system(size:24))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.gray)
                                Image("\(selected.name)_南京錠")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 180)
                                    .cornerRadius(15)
                                    .frame(height:180)
                            }
                        }
                        HStack{
                            Image("ハート")
                                .resizable()
                                .frame(width: 30,height:30)
                                .padding(.trailing,-8)
                            Text("\(selected.condition)")
                                .font(.system(size:20))
                                .foregroundColor(Color("fontGray"))
                        }
                    }
                }
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(allItems) { item in
                            VStack{
                                // ユーザーが持っているアバターの判定
                                if authManager.backgrounds.contains(where: { $0.name == item.name }) {
                                    // ユーザーが持っているアバターの画像を表示
                                    Button(action: {
                                        if selectedItem?.name == item.name {
                                            // すでに選択されているアイテムが再度選択された場合
                                            if previouslySelectedItemName == item.name {
                                                // ここでアラートを表示するなどのアクションを実行
                                                self.switchingBackground = item
                                                self.showingAlert2 = true
                                            }
                                        } else {
                                            print("#")
                                            // 新しいアイテムが選択された場合、それを記録
                                            previouslySelectedItemName = item.name
                                        }
                                        selectedItem = item
                                        audioManager.playSound()
                                    }) {
                                        Image(item.name)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 100, height: 100)
                                            .padding(5)
                                            .cornerRadius(8)
                                    }
                                } else {
                                    // ユーザーが持っていないアバターのシルエットを表示
                                    Button(action: {
                                        selectedItem = item
                                        audioManager.playSound()
                                    }) {
                                        Image("\(item.name)_南京錠") // シルエット画像は適宜用意してください
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 100, height: 100)
                                    }
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke((selectedItem?.name == item.name) ? Color.gray : Color.clear, lineWidth: 4)
                            )
                            .padding(.top,5)
                        }
                    }
                }
                .alert(isPresented: $showingAlert2) {
                    Alert(
                        title: Text("エリアを切り替えますか？"),
                        primaryButton: .default(Text("はい"), action: {
                            // はいを選択した場合、usedFlagを更新
                            if let switchingBackground = switchingBackground {
                                authManager.switchBackground(to: Background(name:  switchingBackground.name, usedFlag: 1)) { success in
                                    if success {
                                        print("Avatar successfully added!")
                                        changeFlag = true
                                    } else {
                                        print("Failed to add avatar.")
                                    }
                                }
                            }
                            audioManager.playChangeSound()
                        }),
                        secondaryButton: .cancel(Text("キャンセル"))
                    )
                }
                
                Spacer()
            }
        }
        .frame(maxWidth:.infinity,maxHeight:.infinity)
//            .padding(.top)
//            .onReceive(authManager.$backgrounds) { newbackgrounds in
//                if let updatedbackground = newbackgrounds.first(where: { $0.usedFlag == 1 }) {
////                            print(updatedbackground)
//                    self.selectedItem = updatedbackground
//                }
//            }
//            .onReceive(authManager.backgrounds) { newBackgrounds in
//                print("aaa")
//                        // avatarsが更新されたときに呼ばれる
//                        if let updatedBackground = newBackgrounds.first(where: { $0.usedFlag == 1 }) {
////                            print(updatedAvatar)
//                            self.usedBackground = updatedBackground
//                        }
//                    }
        .onChange(of: changeFlag) { _ in
            authManager.fetchUsedBackgrounds { usedBackgrounds in
                self.usedBackground = usedBackgrounds.first { $0.usedFlag == 1 }
            }
            changeFlag = false
        }
        .onAppear {
            authManager.fetchUsedBackgrounds { usedBackgrounds in
                self.usedBackground = usedBackgrounds.first { $0.usedFlag == 1 }
            }
            self.selectedItem = Item(name: "背景1", imageName: "お部屋", condition: "", attack: 10, probability: 25,health: 20, rarity: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("authManager.backgrounds:\(authManager.backgrounds)")
                authManager.fetchBackgrounds {
                    for item in allItems {
                        let contains = authManager.backgrounds.contains(where: { $0.name == item.name })
                        print("Contains \(item.name): \(contains)")
                    }
                }
            }
        }
        .padding(.top,5)
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
        .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("おとも図鑑")
                        .font(.system(size: 20)) // ここでフォントサイズを指定
                        .foregroundColor(Color("fontGray"))
                }
            }
        }
    }

#Preview {
    BackgroundView()
}
