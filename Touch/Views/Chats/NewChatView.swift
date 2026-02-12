import SwiftUI
import Contacts

struct NewChatView: View {
    @Environment(ChatViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var contacts: [ContactItem] = []
    @State private var hasContactsAccess = false

    var body: some View {
        NavigationStack {
            List {
                // Username search section
                if !searchText.isEmpty {
                    Section {
                        Button {
                            startChat(with: searchText.trimmingCharacters(in: .whitespacesAndNewlines))
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 40, height: 40)
                                    .background(Color(.systemGray5))
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(searchText)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                    Text("Search by username")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                // Contacts section
                if hasContactsAccess {
                    Section("Contacts") {
                        ForEach(filteredContacts) { contact in
                            Button {
                                startChat(with: contact.name)
                            } label: {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.blue.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text(String(contact.name.prefix(1)).uppercased())
                                                .font(.headline)
                                                .foregroundStyle(.blue)
                                        )

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(contact.name)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                        if let phone = contact.phone {
                                            Text(phone)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Section {
                        Button {
                            requestContactsAccess()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.blue)
                                Text("Allow access to contacts")
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("New Chat")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search by username or contact")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                checkContactsAccess()
            }
        }
    }

    private var filteredContacts: [ContactItem] {
        if searchText.isEmpty {
            return contacts
        }
        return contacts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func startChat(with name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        viewModel.createChat(contactName: trimmed)
        dismiss()
    }

    private func checkContactsAccess() {
        let store = CNContactStore()
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .authorized {
            hasContactsAccess = true
            loadContacts(store: store)
        }
    }

    private func requestContactsAccess() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, _ in
            DispatchQueue.main.async {
                hasContactsAccess = granted
                if granted {
                    loadContacts(store: store)
                }
            }
        }
    }

    private func loadContacts(store: CNContactStore) {
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        request.sortOrder = .givenName

        DispatchQueue.global(qos: .userInitiated).async {
            var result: [ContactItem] = []
            try? store.enumerateContacts(with: request) { contact, _ in
                let fullName = [contact.givenName, contact.familyName]
                    .filter { !$0.isEmpty }
                    .joined(separator: " ")
                guard !fullName.isEmpty else { return }
                let phone = contact.phoneNumbers.first?.value.stringValue
                result.append(ContactItem(name: fullName, phone: phone))
            }

            DispatchQueue.main.async {
                self.contacts = result
            }
        }
    }
}

struct ContactItem: Identifiable {
    let id = UUID()
    let name: String
    let phone: String?
}
