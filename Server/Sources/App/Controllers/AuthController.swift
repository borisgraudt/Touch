import Vapor
import Fluent
import JWT

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("api", "auth")
        auth.post("send-code", use: sendCode)
        auth.post("verify-code", use: verifyCode)
    }

    // MARK: - Send Code

    struct SendCodeRequest: Content {
        let phoneNumber: String
    }

    struct SendCodeResponse: Content {
        let message: String
    }

    func sendCode(req: Request) async throws -> SendCodeResponse {
        let input = try req.content.decode(SendCodeRequest.self)
        let phone = input.phoneNumber.trimmingCharacters(in: .whitespaces)

        guard phone.count >= 10 else {
            throw Abort(.badRequest, reason: "Invalid phone number")
        }

        let code = String(format: "%06d", Int.random(in: 0..<1_000_000))
        let expiresAt = Date().addingTimeInterval(5 * 60)

        if let user = try await User.query(on: req.db)
            .filter(\.$phoneNumber == phone)
            .first()
        {
            user.verificationCode = code
            user.codeExpiresAt = expiresAt
            try await user.update(on: req.db)
        } else {
            let user = User(phoneNumber: phone)
            user.verificationCode = code
            user.codeExpiresAt = expiresAt
            try await user.create(on: req.db)
        }

        let twilio = TwilioService(app: req.application)
        try await twilio.send(to: phone, message: "Your Touch code: \(code)")

        return SendCodeResponse(message: "Code sent")
    }

    // MARK: - Verify Code

    struct VerifyCodeRequest: Content {
        let phoneNumber: String
        let code: String
    }

    struct UserResponse: Content {
        let id: UUID
        let phoneNumber: String
        let displayName: String
    }

    struct VerifyCodeResponse: Content {
        let token: String
        let user: UserResponse
    }

    func verifyCode(req: Request) async throws -> VerifyCodeResponse {
        let input = try req.content.decode(VerifyCodeRequest.self)

        guard let user = try await User.query(on: req.db)
            .filter(\.$phoneNumber == input.phoneNumber)
            .first()
        else {
            throw Abort(.notFound, reason: "User not found")
        }

        guard let storedCode = user.verificationCode,
              let expiresAt = user.codeExpiresAt
        else {
            throw Abort(.badRequest, reason: "No code requested")
        }

        guard storedCode == input.code else {
            throw Abort(.badRequest, reason: "Invalid code")
        }

        guard Date() < expiresAt else {
            throw Abort(.badRequest, reason: "Code expired")
        }

        user.isVerified = true
        user.verificationCode = nil
        user.codeExpiresAt = nil
        try await user.update(on: req.db)

        let payload = AuthPayload(userID: user.id!)
        let token = try req.jwt.sign(payload)

        return VerifyCodeResponse(
            token: token,
            user: UserResponse(
                id: user.id!,
                phoneNumber: user.phoneNumber,
                displayName: user.displayName
            )
        )
    }
}
