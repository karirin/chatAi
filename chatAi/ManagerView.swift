//
//  ManagerView.swift
//  chatAi
//
//  Created by Apple on 2024/02/18.
//

import SwiftUI

struct TopTabView: View {
    let list: [String]
    @Binding var selectedTab: Int
    
    var body: some View {
        
        HStack(spacing: 0) {
            ForEach(0 ..< list.count, id: \.self) { row in
                Button(action: {
                    withAnimation {
                        selectedTab = row
                    }
                }, label: {
                    VStack(spacing: 0) {
                        HStack {
                            Text(list[row])
                                .font(Font.system(size: 18, weight: .semibold))
                                .foregroundColor(Color("fontGray"))
                        }
                        .frame(
                            width: (UIScreen.main.bounds.width / CGFloat(list.count)),
                            height: 48 - 3
                        )
                        Rectangle()
                            .fill(selectedTab == row ? Color("loading") : Color.clear)
                            .frame(height: 3)
                    }
                    .fixedSize()
                })
            }
        }
        .frame(height: 48)
        .background(Color.white)
        .compositingGroup()
        .shadow(color: .primary.opacity(0.2), radius: 3, x: 4, y: 4)
    }
}

struct ManagerView: View {
    @ObservedObject var audioManager : AudioManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: Int = 0
    @State private var canSwipe: Bool = false
    @State private var showLoginModal: Bool = false
    @State private var isButtonClickable: Bool = false
    let list: [String] = ["おとも", "お宝", "エリア"]
    
    var body: some View {
        VStack{
            TopTabView(list: list, selectedTab: $selectedTab)
            
            TabView(selection: $selectedTab,
                    content: {
                AvatarListView()
                    .tag(0)
                TreasureListView()
                    .tag(1)
                BackgroundView()
                    .tag(2)
            })
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            audioManager.playCancelSound()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(Color("fontGray"))
            Text("戻る")
                .foregroundColor(Color("fontGray"))
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("ダンジョン一覧")
                    .font(.system(size: 20)) // ここでフォントサイズを指定
                    .foregroundStyle(Color("fontGray"))
            }
        }
        .background(Color("Color2"))
    }
}

#Preview {
    ManagerView(audioManager: AudioManager())
}
