import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        "Touch Server is running"
    }

    try app.register(collection: AuthController())
    try app.register(collection: ChatController())
}
