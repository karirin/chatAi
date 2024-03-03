//
//  ModalBackgroundView.swift
//  chatAi
//
//  Created by Apple on 2024/02/20.
//

import SwiftUI

struct ModalBackgroundView: View {
    @Binding var showLevelUpModal: Bool
    @ObservedObject var authManager: AuthManager
    @ObservedObject var audioManager = AudioManager.shared
    @Binding var backgroundNumber: Int

    var body: some View {
        ZStack {
            // 半透明の背景
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showLevelUpModal = false
                }

            VStack(spacing: 20) {
//                    .padding(.bottom,80)
                if backgroundNumber == 1 {
                    Text("エリア解放")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                    .foregroundColor(Color("fontGray"))
                    Image("背景2")
                        .resizable()
                        .frame(width:320,height:200)
                    Text("「大草原」エリアを解放しました")
                        .font(.system(size: 22))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if backgroundNumber == 2 {
                    Text("エリア解放")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                    .foregroundColor(Color("fontGray"))
                    Image("背景3")
                        .resizable()
                        .frame(width:320,height:200)
                    Text("「海中」エリアを解放しました")
                        .font(.system(size: 22))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if backgroundNumber == 3 {
                    Text("エリア解放")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                    .foregroundColor(Color("fontGray"))
                    Image("背景4")
                        .resizable()
                        .frame(width:320,height:200)
                    Text("「洞窟」エリアを解放しました")
                        .font(.system(size: 22))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if backgroundNumber == 4 {
                    Text("エリア解放")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                    .foregroundColor(Color("fontGray"))
                    Image("背景5")
                        .resizable()
                        .frame(width:320,height:200)
                    Text("「宇宙」エリアを解放しました")
                        .font(.system(size: 22))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
        }
        .overlay(
            // 「×」ボタンを右上に配置
            Button(action: {
                showLevelUpModal = false
                audioManager.playCancelSound()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .foregroundColor(.black)
                    .background(.white)
                    .cornerRadius(50)
                    .padding()
            }
            .offset(x: 160, y: -160)
        )
        .onAppear{
//            authManager.fetchUserExperienceAndLevel()
            audioManager.playTittleSound()
        }
    }
}

struct ModalBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        let authManager = AuthManager()
        ModalBackgroundView(showLevelUpModal: .constant(true), authManager: authManager, backgroundNumber: .constant(02))
    }
}


