import SwiftUI

struct ChatsView: View {
    @Environment(ChatViewModel.self) private var viewModel
    @State private var showNewChat = false
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.sortedChats.isEmpty {
                    VStack(spacing: 6) {
                        Text("No chats yet.")
                            .fontWeight(.semibold)
                        Text("Get started by messaging a friend.")
                            .foregroundStyle(Color(.systemGray))
                    }
                } else {
                    List {
                        ForEach(filteredChats) { chat in
                            NavigationLink(destination: ChatDetailView(chat: chat)) {
                                ChatRow(chat: chat)
                            }
                        }
                        .onDelete(perform: viewModel.deleteChat)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AvatarView()
                }
                ToolbarItem(placement: .principal) {
                    Text("Chats")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewChat = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 18))
                            .foregroundStyle(.primary)
                            .frame(width: 32, height: 32)

                                    
                        
                    }
                }
            }
            .sheet(isPresented: $showNewChat) {
                NewChatView()
            }
        }
    }

    private var filteredChats: [Chat] {
        if searchText.isEmpty {
            return viewModel.sortedChats
        }
        return viewModel.sortedChats.filter {
            $0.contactName.localizedCaseInsensitiveContains(searchText)
        }
    }
}

// MARK: - Avatar

struct AvatarView: View {
    var body: some View {
        Image(systemName: "person.crop.circle.fill")
            .font(.system(size: 26))
            .symbolRenderingMode(.palette)
            .foregroundStyle(.black, Color(.systemGray5))
    }
}

// MARK: - Chat Row

struct ChatRow: View {
    let chat: Chat

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(chat.contactName.prefix(1)).uppercased())
                        .font(.title2)
                        .foregroundStyle(.blue)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(chat.contactName)
                    .font(.headline)
                Text(chat.lastMessageText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(chat.lastMessageDate, style: .time)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
