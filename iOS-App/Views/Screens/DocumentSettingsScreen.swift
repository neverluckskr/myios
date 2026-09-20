import SwiftUI
import UniformTypeIdentifiers

struct DocumentSettingsScreen: View {
    @Environment(DocumentStore.self) private var store

    @State private var backupURL: URL?
    @State private var isImporting = false
    @State private var importError: String?

    var body: some View {
        ZStack {
            FormPalette.canvas.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    DiiaFormSection(title: "Документи", icon: "square.stack") {
                        VStack(spacing: 10) {
                            ForEach(store.documents) { document in
                                NavigationLink {
                                    DocumentEditScreen(document: document)
                                } label: {
                                    row(for: document)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    DiiaFormSection(title: "Копія даних", icon: "arrow.up.arrow.down") {
                        if let backupURL {
                            ShareLink(item: backupURL) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 15, weight: .medium))
                                    Text("Зберегти копію")
                                        .font(.system(size: 17))
                                }
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(FormPalette.inputIdle)
                                .clipShape(Capsule())
                            }
                        }

                        DiiaFormButton(title: "Відновити з копії", icon: "square.and.arrow.down") {
                            isImporting = true
                        }

                        Text("Копія містить усі документи разом із фото. Відновлення замінить поточні дані.")
                            .font(.system(size: 12))
                            .foregroundStyle(FormPalette.caption)
                            .padding(.leading, 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Налаштування")
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

    private func row(for document: DiiaDocument) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(document.title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.black)

                Text(document.fullName.replacingOccurrences(of: "\n", with: " "))
                    .font(.system(size: 13))
                    .foregroundStyle(FormPalette.caption)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(FormPalette.caption)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FormPalette.inputIdle)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        DocumentSettingsScreen().environment(DocumentStore())
    }
}
