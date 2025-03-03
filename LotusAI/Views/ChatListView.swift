//
//  ChatListView.swift
//  LotusAI
//
//  Created on 3/2/25.
//

import SwiftUI
import SwiftData

struct ChatListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Chat.updatedAt, order: .reverse) private var chats: [Chat]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(chats) { chat in
                    NavigationLink {
                        ChatView(chat: chat, modelContext: modelContext)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(chat.title)
                                .font(.headline)
                            
                            if let lastMessage = chat.messages.sorted(by: { $0.timestamp > $1.timestamp }).first {
                                Text(lastMessage.text)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Text(chat.updatedAt, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteChats)
            }
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: createNewChat) {
                        Label("New Chat", systemImage: "square.and.pencil")
                    }
                }
            }
        }
    }
    
    private func createNewChat() {
        let newChat = Chat()
        modelContext.insert(newChat)
    }
    
    private func deleteChats(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(chats[index])
        }
    }
}

#Preview {
    ChatListView()
        .modelContainer(for: Chat.self, inMemory: true)
}
