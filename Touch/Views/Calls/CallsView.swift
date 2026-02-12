import SwiftUI

struct CallsView: View {
    @State private var selectedFilter: CallFilter = .all
    @State private var searchText = ""

    enum CallFilter: String, CaseIterable, Identifiable {
        var id: String { rawValue }
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
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(CallFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 160)
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
