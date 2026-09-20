import Foundation
import Observation

@Observable
final class DocumentStore {
    private static let storageKey = "diia.documents"

    var documents: [DiiaDocument] {
        didSet { persist() }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode([DiiaDocument].self, from: data) {
            documents = decoded
        } else {
            documents = DiiaDocument.mocks
        }
    }

    func update(_ document: DiiaDocument) {
        guard let index = documents.firstIndex(where: { $0.id == document.id }) else { return }
        documents[index] = document
    }

    /// Restores the shipped defaults for one document, keeping its identity so
    /// the carousel does not jump.
    func resetToDefaults(id: UUID) -> DiiaDocument? {
        guard let index = documents.firstIndex(where: { $0.id == id }),
              index < DiiaDocument.mocks.count else { return nil }

        var fresh = DiiaDocument.mocks[index]
        fresh.id = id
        documents[index] = fresh
        return fresh
    }

    /// Writes the whole set, photos included, to a file the share sheet can
    /// hand off — so a reset or a reinstall no longer means retyping.
    func writeBackup() throws -> URL {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("morty-documents.json")
        try encoder.encode(documents).write(to: url, options: .atomic)
        return url
    }

    func restoreBackup(from url: URL) throws {
        let needsRelease = url.startAccessingSecurityScopedResource()
        defer { if needsRelease { url.stopAccessingSecurityScopedResource() } }

        let data = try Data(contentsOf: url)
        documents = try JSONDecoder().decode([DiiaDocument].self, from: data)
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(documents) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
