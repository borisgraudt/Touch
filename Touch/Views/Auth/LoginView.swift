import SwiftUI

struct LoginView: View {

    @Environment(UserProfile.self) private var profile

    @State private var phone = ""
    @State private var code = ""
    @State private var step: Step = .phone
    @State private var isLoading = false

    @FocusState private var focused: Bool

    enum Step {
        case phone, code
    }

    var body: some View {
        VStack(spacing: 16) {

            Spacer()

            if step == .phone {
                TextField("Phone number", text: $phone)
                    .keyboardType(.phonePad)
                    .focused($focused)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .glassCard()

                Button {
                    sendCode()
                } label: {
                    Text("Continue")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .glassCard()
                .disabled(phone.isEmpty || isLoading)
                .opacity(phone.isEmpty ? 0.4 : 1)
            } else {
                Text("Code sent to \(phone)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("SMS code", text: $code)
                    .keyboardType(.numberPad)
                    .focused($focused)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .glassCard()

                Button {
                    verify()
                } label: {
                    ZStack {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Verify")
                                .fontWeight(.medium)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .glassCard()
                .disabled(code.isEmpty || isLoading)
                .opacity(code.isEmpty ? 0.4 : 1)

                Button("Change number") {
                    withAnimation { step = .phone }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

            if let error = profile.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
        .background(Color(.systemBackground))
        .animation(.default, value: step)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                focused = true
            }
        }
    }

    private func sendCode() {
        Task {
            isLoading = true
            await profile.sendCode(to: phone)
            isLoading = false
            if profile.errorMessage == nil {
                step = .code
                focused = true
            }
        }
    }

    private func verify() {
        Task {
            isLoading = true
            _ = await profile.verifyCode(code, for: phone)
            isLoading = false
        }
    }
}

// MARK: - Glass Card

extension View {
    func glassCard() -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.primary.opacity(0.08), lineWidth: 1)
            )
    }
}

#Preview {
    LoginView()
        .environment(UserProfile())
}
