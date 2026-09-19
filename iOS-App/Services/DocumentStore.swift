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

    private func persist() {
        guard let data = try? JSONEncoder().encode(documents) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
