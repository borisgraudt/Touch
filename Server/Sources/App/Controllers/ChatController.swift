import Vapor
import Fluent
import JWT

struct ChatController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")

        // Protected routes
        let protected = api.grouped(JWTAuthMiddleware())
        protected.get("chats", use: listChats)
        protected.post("chats", use: createChat)
        protected.delete("chats", ":chatID", use: deleteChat)
        protected.get("chats", ":chatID", "messages", use: getMessages)
        protected.post("chats", ":chatID", "messages", use: sendMessage)
        protected.get("users", "search", use: searchUsers)
    }

    // MARK: - List Chats

    struct ChatResponse: Content {
        let id: UUID
        let contactName: String
        let contactPhone: String
        let isMuted: Bool
        let isPinned: Bool
        let lastMessage: String?
        let lastMessageDate: Date?
        let createdAt: Date?
    }

    func listChats(req: Request) async throws -> [ChatResponse] {
        let userID = try req.auth.require(AuthPayload.self).userID

        let chats = try await Chat.query(on: req.db)
            .filter(\.$user.$id == userID)
            .with(\.$messages)
            .all()

        return chats.map { chat in
            let lastMsg = chat.messages.sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }.last
            return ChatResponse(
                id: chat.id!,
                contactName: chat.contactName,
                contactPhone: chat.contactPhone,
                isMuted: chat.isMuted,
                isPinned: chat.isPinned,
                lastMessage: lastMsg?.text,
                lastMessageDate: lastMsg?.createdAt,
                createdAt: chat.createdAt
            )
        }
    }

    // MARK: - Create Chat

    struct CreateChatRequest: Content {
        let contactName: String
        let contactPhone: String
    }

    func createChat(req: Request) async throws -> ChatResponse {
        let userID = try req.auth.require(AuthPayload.self).userID
        let input = try req.content.decode(CreateChatRequest.self)

        // Get current user
        guard let currentUser = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }

        // Find contact user
        guard let contactUser = try await User.query(on: req.db)
            .filter(\.$phoneNumber == input.contactPhone)
            .first()
        else {
            throw Abort(.notFound, reason: "Contact not found")
        }

        // Create my chat
        let myChat = Chat(userID: userID, contactName: input.contactName, contactPhone: input.contactPhone)
        try await myChat.create(on: req.db)

        // Create mirror chat for the other user
        let mirrorChat = Chat(userID: contactUser.id!, contactName: currentUser.displayName, contactPhone: currentUser.phoneNumber)
        try await mirrorChat.create(on: req.db)

        // Link them
        myChat.linkedChatID = mirrorChat.id
        mirrorChat.linkedChatID = myChat.id
        try await myChat.update(on: req.db)
        try await mirrorChat.update(on: req.db)

        return ChatResponse(
            id: myChat.id!,
            contactName: myChat.contactName,
            contactPhone: myChat.contactPhone,
            isMuted: myChat.isMuted,
            isPinned: myChat.isPinned,
            lastMessage: nil,
            lastMessageDate: nil,
            createdAt: myChat.createdAt
        )
    }

    // MARK: - Delete Chat

    func deleteChat(req: Request) async throws -> HTTPStatus {
        let userID = try req.auth.require(AuthPayload.self).userID

        guard let chatID = req.parameters.get("chatID", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        guard let chat = try await Chat.query(on: req.db)
            .filter(\.$id == chatID)
            .filter(\.$user.$id == userID)
            .first()
        else {
            throw Abort(.notFound)
        }

        try await chat.delete(on: req.db)
        return .noContent
    }

    // MARK: - Get Messages

    struct MessageResponse: Content {
        let id: UUID
        let text: String
        let senderID: UUID
        let isFromMe: Bool
        let createdAt: Date?
    }

    func getMessages(req: Request) async throws -> [MessageResponse] {
        let userID = try req.auth.require(AuthPayload.self).userID

        guard let chatID = req.parameters.get("chatID", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        // Verify chat belongs to user
        guard let _ = try await Chat.query(on: req.db)
            .filter(\.$id == chatID)
            .filter(\.$user.$id == userID)
            .first()
        else {
            throw Abort(.notFound)
        }

        let messages = try await Message.query(on: req.db)
            .filter(\.$chat.$id == chatID)
            .sort(\.$createdAt)
            .all()

        return messages.map { msg in
            MessageResponse(
                id: msg.id!,
                text: msg.text,
                senderID: msg.$sender.id,
                isFromMe: msg.$sender.id == userID,
                createdAt: msg.createdAt
            )
        }
    }

    // MARK: - Send Message

    struct SendMessageRequest: Content {
        let text: String
    }

    func sendMessage(req: Request) async throws -> MessageResponse {
        let userID = try req.auth.require(AuthPayload.self).userID

        guard let chatID = req.parameters.get("chatID", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        guard let chat = try await Chat.query(on: req.db)
            .filter(\.$id == chatID)
            .filter(\.$user.$id == userID)
            .first()
        else {
            throw Abort(.notFound)
        }

        let input = try req.content.decode(SendMessageRequest.self)

        // Save message in my chat
        let message = Message(chatID: chatID, senderID: userID, text: input.text)
        try await message.create(on: req.db)

        // Also save in the linked (mirror) chat so the other user sees it
        if let linkedID = chat.linkedChatID {
            let mirrorMessage = Message(chatID: linkedID, senderID: userID, text: input.text)
            try await mirrorMessage.create(on: req.db)
        }

        return MessageResponse(
            id: message.id!,
            text: message.text,
            senderID: userID,
            isFromMe: true,
            createdAt: message.createdAt
        )
    }

    // MARK: - Search Users

    struct SearchUserResponse: Content {
        let id: UUID
        let phoneNumber: String
        let displayName: String
    }

    func searchUsers(req: Request) async throws -> [SearchUserResponse] {
        let currentUserID = try req.auth.require(AuthPayload.self).userID

        guard let phone = req.query[String.self, at: "phone"], !phone.isEmpty else {
            return []
        }

        let users = try await User.query(on: req.db)
            .filter(\.$phoneNumber ~~ phone)
            .filter(\.$isVerified == true)
            .filter(\.$id != currentUserID)
            .limit(20)
            .all()

        return users.map { user in
            SearchUserResponse(
                id: user.id!,
                phoneNumber: user.phoneNumber,
                displayName: user.displayName
            )
        }
    }
}

// MARK: - JWT Auth Middleware

struct JWTAuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let payload = try request.jwt.verify(as: AuthPayload.self)
        request.auth.login(payload)
        return try await next.respond(to: request)
    }
}
