import SwiftUI

struct NewChatView: View {
    @Environment(ChatViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var results: [APIClient.SearchUserResponse] = []
    @State private var isSearching = false

    private let api = APIClient.shared

    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty {
                    ContentUnavailableView(
                        "Search for users",
                        systemImage: "magnifyingglass",
                        description: Text("Find people by phone number")
                    )
                } else if isSearching {
                    ProgressView()
                } else if results.isEmpty {
                    ContentUnavailableView(
                        "No users found",
                        systemImage: "person.slash",
                        description: Text("No users matching \"\(searchText)\"")
                    )
                } else {
                    List(results, id: \.id) { user in
                        Button {
                            startChat(with: user)
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(String(user.displayName.prefix(1)).uppercased())
                                            .font(.headline)
                                            .foregroundStyle(.blue)
                                    )

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(user.displayName)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    Text(user.phoneNumber)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("New Chat")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Phone number")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: searchText) {
                search()
            }
        }
    }

    private func search() {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else {
            results = []
            return
        }

        Task {
            isSearching = true
            do {
                results = try await api.searchUsers(phone: query)
            } catch {
                results = []
            }
            isSearching = false
        }
    }

    private func startChat(with user: APIClient.SearchUserResponse) {
        Task {
            _ = await viewModel.createChat(contactName: user.displayName, contactPhone: user.phoneNumber)
            dismiss()
        }
    }
}
