//
//  ContactView.swift
//  chatAi
//
//  Created by Apple on 2024/02/23.
//

import SwiftUI

struct ContactView: View {
    @State private var text: String = ""
    @State private var showAlert = false
    @ObservedObject var authManager = AuthManager.shared

    var body: some View {
        VStack(spacing: -25) {
            HStack{
                Spacer()
                Text("お問合せ")
                    .font(.system(size:24))
                Spacer()
            }
            .padding(.top)
            Spacer()
                .frame(height: isSmallDevice() ? 100 : 120)
            Image("カスタマーライム")
                .resizable()
                .frame(width:isSmallDevice() ? 150 : 200,height:isSmallDevice() ? 150 : 200)
            Spacer()
                .frame(height: 80)
            VStack(alignment: .center){
                Text("改善してほしい点や\n追加を希望する機能などありましたら\nお気軽にご連絡ください\n可能な限りご要望にお応えいたします")
                    .font(.system(size:20))
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                Spacer()
                    .frame(height: isSmallDevice() ? 0 : 50)
                    TextField(
                        "",
                        text: $text,
                        axis: .vertical
                    )
                    .padding()
                    .background(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal)
                Button(action: {
                    authManager.updateContact(userId: authManager.currentUserId!, newContact: text){ success in
                        self.showAlert = true
                        self.text = ""
                    }
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }, label: {
                    Text("送信")
                        .fontWeight(.semibold)
                        .frame(width: 130, height:40)
                        .foregroundColor(Color.white)
                        .background(Color.gray)
                        .cornerRadius(24)
                })
                .shadow(radius: 3)
                .padding(.top,10)
                .alert(isPresented: $showAlert) { // アラートを表示する
                    Alert(
                        title: Text("送信されました"),
                        message: Text("お問合せありがとうございます"),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            Spacer()
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .foregroundColor(Color("fontGray"))
        .frame(maxHeight:.infinity)
        .background(Color("background"))
    }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}

#Preview {
    ContactView()
}

