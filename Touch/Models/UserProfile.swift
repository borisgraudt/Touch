import SwiftUI
import PhotosUI

@Observable
class UserProfile {
    var username: String {
        didSet { save() }
    }
    var displayName: String {
        didSet { save() }
    }
    var avatarData: Data? {
        didSet { save() }
    }

    var avatarImage: Image? {
        guard let data = avatarData, let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }

    var isLoggedIn: Bool {
        !username.isEmpty
    }

    init() {
        let defaults = UserDefaults.standard
        self.username = defaults.string(forKey: "username") ?? ""
        self.displayName = defaults.string(forKey: "displayName") ?? ""
        self.avatarData = defaults.data(forKey: "avatarData")
    }

    func save() {
        let defaults = UserDefaults.standard
        defaults.set(username, forKey: "username")
        defaults.set(displayName, forKey: "displayName")
        defaults.set(avatarData, forKey: "avatarData")
    }

    func logout() {
        username = ""
        displayName = ""
        avatarData = nil
    }
}
