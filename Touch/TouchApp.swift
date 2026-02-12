import SwiftUI

@main
struct MessengerApp: App {
    @State private var chatViewModel = ChatViewModel()
    @State private var userProfile = UserProfile()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(chatViewModel)
                .environment(userProfile)
        }
    }
}
