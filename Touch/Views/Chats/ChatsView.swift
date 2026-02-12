import SwiftUI

struct ChatsView: View {
    @Environment(ChatViewModel.self) private var viewModel
    @Environment(UserProfile.self) private var profile
    @State private var showNewChat = false
    @State private var showSettings = false
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
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteChat(id: chat.id)
                                } label: {
                                    Image(systemName: "trash.fill")
                                }

                                Button {
                                    viewModel.toggleMute(id: chat.id)
                                } label: {
                                    Image(systemName: chat.isMuted ? "bell.fill" : "bell.slash.fill")
                                }
                                .tint(.orange)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    viewModel.togglePin(id: chat.id)
                                } label: {
                                    Image(systemName: chat.isPinned ? "pin.slash.fill" : "pin.fill")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        AvatarView()
                    }
                    .buttonStyle(.plain)
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
            .sheet(isPresented: $showSettings) {
                SettingsView()
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
    @Environment(UserProfile.self) private var profile

    var body: some View {
        if let avatarImage = profile.avatarImage {
            avatarImage
                .resizable()
                .scaledToFill()
                .frame(width: 22, height: 22)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 22))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.black, Color(.systemGray5))
        }
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
