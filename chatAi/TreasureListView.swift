//
//  TreasureListView.swift
//  chatAi
//
//  Created by Apple on 2024/02/18.
//

import SwiftUI
import Firebase

struct TreasureListView: View {
    let items = ["もりこう","ライム", "レッドドラゴン", "レインボードラゴン"]
    
    struct Item: Identifiable {
        let name: String  // これが一意の識別子として機能します
        let attack: String
        let probability: Int
        let health: String
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
        Item(name: "宝1", attack: "マトリョーシカ", probability: 25,health: "レベル３を達成したことを讃える称号", rarity: .normal),
        Item(name: "宝2", attack: "黄金の貯金箱", probability: 25,health: "レベル５を達成したことを讃える称号", rarity: .normal),
        Item(name: "宝3", attack: "クリスタル", probability: 25, health: "レベル１０を達成したことを讃える称号", rarity: .normal),
        Item(name: "宝4", attack: "サファイア蝶々", probability: 25, health: "問題の回答数が３０問を達成したことを讃える称号", rarity: .normal),
        Item(name: "宝5", attack: "レインボートカゲ", probability: 25, health: "問題の回答数が５０問を達成したことを讃える称号", rarity: .normal),
        Item(name: "宝6", attack: "琥珀", probability: 25, health: "問題の回答数が５０問を達成したことを讃える称号", rarity: .normal),
        Item(name: "宝7", attack: "真珠", probability: 25, health: "問題の回答数が５０問を達成したことを讃える称号", rarity: .normal),
        Item(name: "宝8", attack: "海賊の宝箱", probability: 25, health: "問題の回答数が５０問を達成したことを讃える称号", rarity: .normal),
        Item(name: "宝9", attack: "スフェーン", probability: 25, health: "問題の回答数が５０問を達成したことを讃える称号", rarity: .normal),
        Item(name: "宝10", attack: "恐竜の化石", probability: 25, health: "問題の回答数が５０問を達成したことを讃える称号", rarity: .normal),
        Item(name: "宝11", attack: "金", probability: 25, health: "問題の回答数が５０問を達成したことを讃える称号", rarity: .normal),
        Item(name: "宝12", attack: "トパーズ", probability: 25, health: "問題の回答数が５０問を達成したことを讃える称号", rarity: .normal),
        Item(name: "宝13", attack: "グレイ", probability: 25, health: "問題の回答数が５０問を達成したことを讃える称号", rarity: .normal),
        Item(name: "宝14", attack: "惑星", probability: 25, health: "問題の回答数が５０問を達成したことを讃える称号", rarity: .normal),
        Item(name: "宝15", attack: "黒曜石", probability: 25, health: "問題の回答数が１００問を達成したことを讃える称号", rarity: .normal)
    ]
    
    @State private var selectedItem: Item?
    @State private var avatars: [String] = []
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var audioManager = AudioManager.shared
    // アラートを表示するかどうかを制御するState変数
    @State private var showingAlert1 = false
    @State private var showingAlert2 = false
    // 切り替えるアバターを保持するState変数
    @State private var switchingAvatar: Avatar?
    // グリッドのレイアウトを定義
    var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var userTreasures: [String: Bool] = [:] // ユーザーの称号データ

    // ユーザーの称号データを取得する関数
    func fetchUserTreasures(userId: String) {
        let treasuresRef = Database.database().reference().child("treasures").child(userId)
        treasuresRef.observeSingleEvent(of: .value) { snapshot in
            if let treasures = snapshot.value as? [String: Bool] {
                self.userTreasures = treasures
                print(self.userTreasures)
            }
        }
    }

    var body: some View {
        VStack{
            if authManager.avatars.isEmpty {
                VStack{
                    ActivityIndicator()
                }
            }else{
                VStack {
                    // 選択されたアイテムを大きく表示
                    if let selected = selectedItem {
                        if userTreasures[selected.name] == true {
                            ZStack{
                                VStack {
                                    Text(selected.attack)
                                        .font(.system(size:28))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.gray)
                                    Image(selected.name)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 180)
                                        .cornerRadius(15)
                                        .frame(height:180)
                                        .padding(.top,5)
                                    //                            Text(selected.health)
                                    //                                .font(.system(size:24))
                                    //                                .foregroundColor(Color("fontGray"))
                                    //                                .padding(.horizontal)
                                    //                                .frame(height:60)
                                }
                            }
                            
                        }else{
                            ZStack{
                                VStack {
                                    Text("???")
                                        .font(.system(size:28))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.gray)
                                        .padding(.top,5)
                                    Image("\(selected.name)_シルエット")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 180)
                                        .cornerRadius(15)
                                        .frame(height:180)
                                    //                            Text(selected.health)
                                    //                                .font(.system(size:24))
                                    //                                .foregroundColor(Color("fontGray"))
                                    //                                .padding(.horizontal)
                                    //                                .frame(height:60)
                                }
                            }
                        }
                    }
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(allItems) { item in
                                VStack{
                                    // ユーザーが持っているアバターの判定
                                    //                                    if authManager.avatars.contains(where: { $0.name == item.name }) {
                                    if userTreasures[item.name] == true {
                                        // ユーザーが持っているアバターの画像を表示
                                        Button(action: {
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
                                            Image("\(item.name)_シルエット") // シルエット画像は適宜用意してください
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
                    .frame(maxWidth:.infinity,maxHeight:.infinity)
                    .onAppear {
                        
                    }
                    //Spacer()
                }
            }
        }
//        .padding(.top,5)
        .onAppear {
            self.fetchUserTreasures(userId: authManager.currentUserId ?? "")
            authManager.fetchAvatars {
                for item in allItems {
                    let contains = authManager.avatars.contains(where: { $0.name == item.name })
                }
            }
            self.selectedItem = Item(name: "宝1", attack: "マトリョーシカ", probability: 25,health: "レベル３を達成したことを讃える称号", rarity: .normal)
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
        .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("称号一覧")
                        .font(.system(size: 20)) // ここでフォントサイズを指定
                        .foregroundColor(Color("fontGray"))
                }
            }
        }
    }

#Preview {
    TreasureListView()
}
