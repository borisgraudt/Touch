import SwiftUI
import PhotosUI

struct SettingsView: View {
    @Environment(UserProfile.self) private var profile
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showLogoutConfirm = false

    var body: some View {
        @Bindable var profile = profile

        NavigationStack {
            List {
                // Avatar section
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                if let avatarImage = profile.avatarImage {
                                    avatarImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 80))
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.black, Color(.systemGray5))
                                }
                            }

                            Text("Change Photo")
                                .font(.footnote)
                                .foregroundStyle(.blue)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }

                // Profile info
                Section("Profile") {
                    HStack {
                        Text("Phone")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(profile.phoneNumber)
                            .foregroundStyle(.primary)
                    }

                    HStack {
                        Text("Display Name")
                            .foregroundStyle(.secondary)
                        Spacer()
                        TextField("Display Name", text: $profile.displayName)
                            .multilineTextAlignment(.trailing)
                    }
                }

                // Logout
                Section {
                    Button(role: .destructive) {
                        showLogoutConfirm = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Log Out")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedPhoto) {
                loadPhoto()
            }
            .confirmationDialog("Log Out?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("Log Out", role: .destructive) {
                    profile.logout()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }

    private func loadPhoto() {
        guard let item = selectedPhoto else { return }
        item.loadTransferable(type: Data.self) { result in
            if case .success(let data) = result {
                DispatchQueue.main.async {
                    profile.avatarData = data
                }
            }
        }
    }
}
