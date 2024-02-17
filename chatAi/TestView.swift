//
//  TestView.swift
//  chatAi
//
//  Created by Apple on 2024/02/16.
//

import SwiftUI

struct BubbleTail: Shape {
    var isUser: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if isUser {
            // ユーザーのメッセージの場合のしっぽ
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + rect.width, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + rect.height))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        } else {
            // AIのメッセージの場合のしっぽ
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - rect.width, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        }
        
        return path
    }
}

struct TestView: View {
    var isUser: Bool = true // 実際の使用では、メッセージの送信者によって変更します。
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .bottomTrailing) {
                Text("message.content!")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.gray.opacity(0.9))
                    .cornerRadius(20)
                    // しっぽの追加
                    .overlay(
                        BubbleTail(isUser: isUser)
                            .fill(Color.gray.opacity(0.9))
                            .frame(width: 20, height: 10)
                            .offset(x: isUser ? -20 : 20, y: 20), // しっぽの位置を調整
                        alignment: isUser ? .bottomLeading : .bottomTrailing // しっぽの向きを調整
                    )
            }
        }
        .padding(.vertical, 5)
        .padding(isUser ? .leading : .trailing, 40) // テキストビューの左側または右側にパディングを追加
    }
}



#Preview {
    TestView()
}
