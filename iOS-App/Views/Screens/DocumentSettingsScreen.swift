import SwiftUI

struct DocumentSettingsScreen: View {
    @Environment(DocumentStore.self) private var store

    var body: some View {
        List {
            ForEach(store.documents) { document in
                NavigationLink {
                    DocumentEditScreen(document: document)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(document.title)
                            .font(DiiaFont.smallHeading)
                            .foregroundStyle(.black)
                        Text(document.fullName.replacingOccurrences(of: "\n", with: " "))
                            .font(DiiaFont.usual)
                            .foregroundStyle(Color.black.opacity(0.5))
                    }
                    .padding(.vertical, 4)
                }
            }
            .listRowBackground(Color.white.opacity(0.4))
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Документи")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DocumentSettingsScreen().environment(DocumentStore())
    }
}
