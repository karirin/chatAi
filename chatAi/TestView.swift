//
//  TestView.swift
//  chatAi
//
//  Created by Apple on 2024/02/16.
//

import SwiftUI

struct TestView: View {
        // 趣味の選択肢
           let hobbies = ["アウトドア", "アート・文化", "ショッピング", "ファッション", "ペット・動物", "エステ", "食事", "読書", "映画鑑賞", "ゲーム", "スポーツ", "漫画", "お笑い"]
           
           // 選択された趣味を追跡するための状態
           @State private var selectedHobbies = Set<String>()
           
        var body: some View {
            NavigationView {
                // スクロール可能なビュー
                ScrollView {
                    // 縦方向のスタック
                    VStack {
                        Text("趣味タグ")
                            .font(.largeTitle)
                            .padding()
                        
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
                    }
                }
                .navigationTitle("趣味・興味があるもの")
            }
        }
    }


//struct HobbyButton: View {
//    var hobby: String
//    var isSelected: Bool
//    var action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            Text(hobby)
//                .padding(8)
//                .frame(width:100)
//                .font(.system(size: 13))
//                .foregroundColor(isSelected ? .white : .black)
//                // ここで`background`に角丸の形を直接指定します。
//                .background(
//                    RoundedRectangle(cornerRadius: 16)
//                        .fill(isSelected ? Color("hpMonsterColor") : Color.white)
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 16)
//                        .stroke(isSelected ? Color.white : Color.gray, lineWidth: 1)
//                )
//        }
//    }
//}



#Preview {
    TestView()
}
