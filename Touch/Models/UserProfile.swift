import SwiftUI
import PhotosUI

@Observable
class UserProfile {

    var errorMessage: String?

    var phoneNumber: String {
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
        !phoneNumber.isEmpty
    }

    private let api = APIClient.shared

    init() {
        let defaults = UserDefaults.standard
        self.phoneNumber = defaults.string(forKey: "phoneNumber") ?? ""
        self.displayName = defaults.string(forKey: "displayName") ?? ""
        self.avatarData = defaults.data(forKey: "avatarData")
    }

    func save() {
        let defaults = UserDefaults.standard
        defaults.set(phoneNumber, forKey: "phoneNumber")
        defaults.set(displayName, forKey: "displayName")
        defaults.set(avatarData, forKey: "avatarData")
    }

    func sendCode(to phone: String) async {
        do {
            try await api.sendCode(phoneNumber: phone)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func verifyCode(_ code: String, for phone: String) async -> Bool {
        do {
            let response = try await api.verifyCode(code, phoneNumber: phone)
            phoneNumber = response.user.phoneNumber
            displayName = response.user.displayName
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func logout() {
        phoneNumber = ""
        displayName = ""
        avatarData = nil
        api.logout()
    }
}
