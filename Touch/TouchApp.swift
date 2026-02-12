import SwiftUI

@main
struct MessengerApp: App {
    @State private var chatViewModel = ChatViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(chatViewModel)
        }
    }
}
