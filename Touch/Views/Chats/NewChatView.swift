import SwiftUI

struct NewChatView: View {
    @Environment(ChatViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var contactName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Contact name", text: $contactName)
                }
            }
            .navigationTitle("New Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let name = contactName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !name.isEmpty else { return }
                        viewModel.createChat(contactName: name)
                        dismiss()
                    }
                    .disabled(contactName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
