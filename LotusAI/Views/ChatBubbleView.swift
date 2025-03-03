//
//  ChatBubbleView.swift
//  LotusAI
//
//  Created on 3/2/25.
//

import SwiftUI

struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.senderType == .user {
                Spacer()
            }
            
            VStack(alignment: message.senderType == .user ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(12)
                    .background(message.senderType == .user ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.senderType == .user ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if message.senderType == .assistant {
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack {
        ChatBubbleView(message: ChatMessage(sender: .user, text: "Hello, how are you?"))
        ChatBubbleView(message: ChatMessage(sender: .assistant, text: "I'm doing well, thank you for asking! How can I help you today?"))
    }
}
