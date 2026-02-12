import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ChatsView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chats")
                }

            CallsView()
                .tabItem {
                    Image(systemName: "phone.fill")
                    Text("Calls")
                }
        }
        .tint(.black)
    }
}

#Preview {
    MainTabView()
        .environment(ChatViewModel())
}
