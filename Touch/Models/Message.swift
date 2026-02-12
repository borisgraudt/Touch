import Foundation

struct Message: Identifiable {
    let id: UUID
    let text: String
    let isFromMe: Bool
    let date: Date

    init(id: UUID = UUID(), text: String, isFromMe: Bool, date: Date = Date()) {
        self.id = id
        self.text = text
        self.isFromMe = isFromMe
        self.date = date
    }
}
