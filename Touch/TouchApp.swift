import SwiftUI

@main
struct MessengerApp: App {
    @State private var chatViewModel = ChatViewModel()
    @State private var userProfile = UserProfile()

    var body: some Scene {
        WindowGroup {
            if userProfile.isLoggedIn {
                MainTabView()
                    .environment(chatViewModel)
                    .environment(userProfile)
            } else {
                LoginView()
                    .environment(userProfile)
                // Note: chatViewModel не добавляем сюда, т.к. он не нужен для логина
            }
        }
    }
}
