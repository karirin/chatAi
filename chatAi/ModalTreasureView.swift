//
//  ModalTreasureView.swift
//  chatAi
//
//  Created by Apple on 2024/02/19.
//

import SwiftUI

struct ModalTreasureView: View {
    @Binding var showLevelUpModal: Bool
    @ObservedObject var authManager: AuthManager
    @ObservedObject var audioManager = AudioManager.shared
    @Binding var treasureNumber: Int

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
                if treasureNumber == 1 {
                    Text("お宝獲得")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                    .foregroundColor(Color("fontGray"))
                    Image("宝1")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("「マトリョーシカ」を獲得しました")
                        .font(.system(size: 22))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if treasureNumber == 2 {
                    Text("お宝獲得")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                        .foregroundColor(Color("fontGray"))
                    Image("宝2")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("「黄金の貯金箱」を獲得しました")
                        .font(.system(size: 22))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if treasureNumber == 3 {
                    Text("お宝獲得")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                        .foregroundColor(Color("fontGray"))
                    Image("宝3")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("「クリスタル」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if treasureNumber == 4 {
                    Text("お宝獲得")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                        .foregroundColor(Color("fontGray"))
                    Image("宝4")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("「サファイア蝶々」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if treasureNumber == 5 {
                    Text("お宝獲得")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                        .foregroundColor(Color("fontGray"))
                    Image("宝5")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("「レインボートカゲ」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if treasureNumber == 6 {
                    Text("お宝獲得")
                        .font(.system(size: 28))
                        .fontWeight(.medium)
                        .foregroundColor(Color("fontGray"))
                    Image("宝6")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("「琥珀」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if treasureNumber == 7 {
                    Text("お宝獲得")
                        .font(.system(size: 28))
                        .fontWeight(.medium)
                        .foregroundColor(Color("fontGray"))
                    Image("宝7")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("「真珠」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if treasureNumber == 8 {
                    Text("お宝獲得")
                        .font(.system(size: 28))
                        .fontWeight(.medium)
                    .foregroundColor(Color("fontGray"))
                    Image("宝8")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("「海賊の宝箱」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                    .foregroundColor(Color("fontGray"))
                } else if treasureNumber == 9 {
                    Text("お宝獲得")
                        .font(.system(size: 28))
                        .fontWeight(.medium)
                    Image("宝9")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("「スフェーン」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                } else if treasureNumber == 10 {
                    Text("お宝獲得")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                        .foregroundColor(Color("fontGray"))
                    Image("宝10")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("「恐竜の化石」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if treasureNumber == 11 {
                    Text("お宝獲得")
                        .font(.system(size: 28))
                        .fontWeight(.medium)
                        .foregroundColor(Color("fontGray"))
                    Image("宝11")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("「金」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if treasureNumber == 12 {
                    Text("お宝獲得")
                        .font(.system(size: 28))
                        .fontWeight(.medium)
                        .foregroundColor(Color("fontGray"))
                    Image("宝12")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("「トパーズ」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("fontGray"))
                } else if treasureNumber == 13 {
                    Text("お宝獲得")
                        .font(.system(size: 28))
                        .fontWeight(.medium)
                    .foregroundColor(Color("fontGray"))
                    Image("宝13")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("「グレイ」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                    .foregroundColor(Color("fontGray"))
                } else if treasureNumber == 14 {
                    Text("お宝獲得")
                        .font(.system(size: 28))
                        .fontWeight(.medium)
                    Image("宝14")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("「惑星」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                } else if treasureNumber == 15 {
                    Text("お宝獲得")
                        .font(.system(size: 28))
                        .fontWeight(.medium)
                    Image("宝15")
                        .resizable()
                        .frame(width:200,height:200)
                    Text("「黒曜石」を獲得しました")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width:300,height:330)
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
            .offset(x: 150, y: -170)
        )
        .onAppear{
//            authManager.fetchUserExperienceAndLevel()
            audioManager.playTittleSound()
        }
    }
}

struct ModalTittleView_Previews: PreviewProvider {
    static var previews: some View {
        let authManager = AuthManager()
        ModalTreasureView(showLevelUpModal: .constant(true), authManager: authManager, treasureNumber: .constant(7))
    }
}

