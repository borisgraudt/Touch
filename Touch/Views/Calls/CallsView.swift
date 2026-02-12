import SwiftUI

struct CallsView: View {
    @State private var selectedFilter: CallFilter = .all
    @State private var searchText = ""

    enum CallFilter: String, CaseIterable {
        case all = "All"
        case missed = "Missed"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Create a Call Link
                HStack(spacing: 12) {
                    Image(systemName: "link")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 40, height: 40)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())

                    Text("Create a Call Link")
                        .font(.body)
                        .fontWeight(.medium)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider()
                    .padding(.leading, 68)

                Spacer()

                switch selectedFilter {
                case .all:
                    VStack(spacing: 6) {
                        Text("No recent calls")
                            .fontWeight(.semibold)
                        Text("Get started by calling a friend")
                            .foregroundStyle(Color(.systemGray))
                    }
                case .missed:
                    VStack(spacing: 6) {
                        Text("No missed calls")
                            .fontWeight(.semibold)
                        Text("You haven't missed any calls")
                            .foregroundStyle(Color(.systemGray))
                    }
                }

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AvatarView()
                }
                ToolbarItem(placement: .principal) {
                    GlassPicker(selection: $selectedFilter)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { } label: {
                        Image(systemName: "phone.badge.plus")
                            .font(.system(size: 18))
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
}

// MARK: - Glass-style segmented picker with sliding animation

struct GlassPicker: View {
    @Binding var selection: CallsView.CallFilter

    private let segmentWidth: CGFloat = 70

    private var selectedIndex: Int {
        CallsView.CallFilter.allCases.firstIndex(of: selection) ?? 0
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // Sliding glass indicator
            Capsule()
                .fill(.thinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
                .frame(width: segmentWidth, height: 32)
                .offset(x: CGFloat(selectedIndex) * segmentWidth + 4)

            // Buttons
            HStack(spacing: 0) {
                ForEach(CallsView.CallFilter.allCases, id: \.self) { filter in
                    Button {
                        withAnimation(.spring(duration: 0.35, bounce: 0.15)) {
                            selection = filter
                        }
                    } label: {
                        Text(filter.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(width: segmentWidth, height: 32)
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        )
    }
}
