import SwiftUI
import UniformTypeIdentifiers

struct DocumentSettingsScreen: View {
    @Environment(DocumentStore.self) private var store

    @State private var backupURL: URL?
    @State private var isImporting = false
    @State private var importError: String?

    var body: some View {
        List {
            Section {
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

            Section {
                if let backupURL {
                    ShareLink(item: backupURL) {
                        Label("Зберегти копію даних", systemImage: "square.and.arrow.up")
                    }
                }

                Button {
                    isImporting = true
                } label: {
                    Label("Відновити з копії", systemImage: "square.and.arrow.down")
                }
            } footer: {
                Text("Копія містить усі документи разом із фото. Відновлення замінить поточні дані.")
            }
            .listRowBackground(Color.white.opacity(0.4))
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Документи")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: store.documents) {
            backupURL = try? store.writeBackup()
        }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) { result in
            do {
                try store.restoreBackup(from: result.get())
            } catch {
                importError = error.localizedDescription
            }
        }
        .alert("Не вдалося відновити", isPresented: .constant(importError != nil)) {
            Button("Гаразд") { importError = nil }
        } message: {
            Text(importError ?? "")
        }
    }
}

#Preview {
    NavigationStack {
        DocumentSettingsScreen().environment(DocumentStore())
    }
}
