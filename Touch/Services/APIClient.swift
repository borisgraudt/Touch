import Foundation

class APIClient {
    static let shared = APIClient()

    // Change this to your Mac's IP when testing on real device
    private let baseURL = "http://172.20.10.4:8080/api"

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }()

    private var token: String? {
        get { UserDefaults.standard.string(forKey: "authToken") }
        set { UserDefaults.standard.set(newValue, forKey: "authToken") }
    }

    // MARK: - Auth

    struct SendCodeResponse: Codable {
        let message: String
    }

    struct VerifyCodeResponse: Codable {
        let token: String
        let user: UserResponse
    }

    struct UserResponse: Codable {
        let id: UUID
        let phoneNumber: String
        let displayName: String
    }

    func sendCode(phoneNumber: String) async throws {
        let body = ["phoneNumber": phoneNumber]
        let _: SendCodeResponse = try await post("auth/send-code", body: body)
    }

    func verifyCode(_ code: String, phoneNumber: String) async throws -> VerifyCodeResponse {
        let body = ["phoneNumber": phoneNumber, "code": code]
        let response: VerifyCodeResponse = try await post("auth/verify-code", body: body)
        token = response.token
        return response
    }

    func logout() {
        token = nil
    }

    // MARK: - Chats

    struct ChatResponse: Codable {
        let id: UUID
        let contactName: String
        let contactPhone: String
        let isMuted: Bool
        let isPinned: Bool
        let lastMessage: String?
        let lastMessageDate: Date?
        let createdAt: Date?
    }

    func fetchChats() async throws -> [ChatResponse] {
        try await get("chats")
    }

    func createChat(contactName: String, contactPhone: String) async throws -> ChatResponse {
        let body = ["contactName": contactName, "contactPhone": contactPhone]
        return try await post("chats", body: body)
    }

    func deleteChat(id: UUID) async throws {
        let _: EmptyResponse = try await delete("chats/\(id.uuidString)")
    }

    // MARK: - Messages

    struct MessageResponse: Codable {
        let id: UUID
        let text: String
        let senderID: UUID
        let isFromMe: Bool
        let createdAt: Date?
    }

    func fetchMessages(chatID: UUID) async throws -> [MessageResponse] {
        try await get("chats/\(chatID.uuidString)/messages")
    }

    func sendMessage(chatID: UUID, text: String) async throws -> MessageResponse {
        let body = ["text": text]
        return try await post("chats/\(chatID.uuidString)/messages", body: body)
    }

    // MARK: - Users

    struct SearchUserResponse: Codable {
        let id: UUID
        let phoneNumber: String
        let displayName: String
    }

    func searchUsers(phone: String) async throws -> [SearchUserResponse] {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove("+")
        let encoded = phone.addingPercentEncoding(withAllowedCharacters: allowed) ?? phone
        return try await get("users/search?phone=\(encoded)")
    }

    // MARK: - Networking

    private struct EmptyResponse: Codable {}

    private func makeURL(_ path: String) -> URL {
        let urlString = "\(baseURL)/\(path)"
        print("[APIClient] \(urlString)")
        return URL(string: urlString)!
    }

    private func get<T: Codable>(_ path: String) async throws -> T {
        var request = URLRequest(url: makeURL(path))
        request.httpMethod = "GET"
        addAuth(&request)
        return try await perform(request)
    }

    private func post<T: Codable>(_ path: String, body: [String: String]) async throws -> T {
        var request = URLRequest(url: makeURL(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        addAuth(&request)
        return try await perform(request)
    }

    private func delete<T: Codable>(_ path: String) async throws -> T {
        var request = URLRequest(url: makeURL(path))
        request.httpMethod = "DELETE"
        addAuth(&request)
        return try await perform(request)
    }

    private func addAuth(_ request: inout URLRequest) {
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

    private func perform<T: Codable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            print("[APIClient] Network error: \(error.localizedDescription)")
            print("[APIClient] URL: \(request.url?.absoluteString ?? "nil")")
            throw error
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        print("[APIClient] \(request.httpMethod ?? "?") \(request.url?.path ?? "") → \(http.statusCode)")

        // For DELETE returning 204 No Content
        if http.statusCode == 204, T.self == EmptyResponse.self {
            return EmptyResponse() as! T
        }

        guard (200...299).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("[APIClient] Server error: \(message)")
            throw APIError.server(statusCode: http.statusCode, message: message)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case server(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .server(let code, let message):
            return "Error \(code): \(message)"
        }
    }
}
