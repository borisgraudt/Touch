import Vapor

struct TwilioService {
    let app: Application

    func send(to phoneNumber: String, message: String) async throws {
        let sid = Environment.get("TWILIO_ACCOUNT_SID") ?? ""
        let token = Environment.get("TWILIO_AUTH_TOKEN") ?? ""
        let from = Environment.get("TWILIO_PHONE_NUMBER") ?? ""

        guard !sid.isEmpty, !token.isEmpty, !from.isEmpty else {
            app.logger.warning("Twilio not configured — SMS not sent. Code is in server logs.")
            app.logger.info("SMS to \(phoneNumber): \(message)")
            return
        }

        let url = URI(string: "https://api.twilio.com/2010-04-01/Accounts/\(sid)/Messages.json")

        let credentials = Data("\(sid):\(token)".utf8).base64EncodedString()

        let response = try await app.client.post(url) { req in
            req.headers.add(name: .authorization, value: "Basic \(credentials)")
            req.headers.add(name: .contentType, value: "application/x-www-form-urlencoded")

            let body = "From=\(from.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? from)&To=\(phoneNumber.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? phoneNumber)&Body=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? message)"
            req.body = ByteBuffer(string: body)
        }

        guard response.status.code >= 200 && response.status.code < 300 else {
            let responseBody = response.body.map { String(buffer: $0) } ?? "no body"
            app.logger.error("Twilio error: \(response.status) — \(responseBody)")
            throw Abort(.internalServerError, reason: "Failed to send SMS")
        }

        app.logger.info("SMS sent to \(phoneNumber)")
    }
}
