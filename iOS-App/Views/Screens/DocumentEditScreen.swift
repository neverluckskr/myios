import SwiftUI
import PhotosUI

struct DocumentEditScreen: View {
    @Environment(DocumentStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: DiiaDocument
    @State private var pickedPhoto: PhotosPickerItem?

    init(document: DiiaDocument) {
        _draft = State(initialValue: document)
    }

    var body: some View {
        Form {
            Section("Документ") {
                TextField("Назва", text: $draft.title)
                TextField("ПІБ", text: $draft.fullName, axis: .vertical)
                TextField("Текст бігучого рядка", text: $draft.tickerText, axis: .vertical)
                TextField("Дані QR-коду", text: Binding(
                    get: { draft.qrPayload ?? "" },
                    set: { draft.qrPayload = $0 }
                ), axis: .vertical)
            }

            Section("Поля") {
                ForEach($draft.fields) { $field in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Підпис", text: $field.label)
                        TextField("Значення", text: $field.value)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { draft.fields.remove(atOffsets: $0) }

                Button("Додати поле") {
                    draft.fields.append(DiiaDocumentField(label: "", value: ""))
                }
            }

            Section("Фото") {
                PhotosPicker(selection: $pickedPhoto, matching: .images) {
                    Label("Обрати фото", systemImage: "photo")
                }

                if draft.photoData != nil {
                    Button("Прибрати фото", role: .destructive) {
                        draft.photoData = nil
                    }
                }
            }

            Section {
                Button("Зберегти") {
                    store.update(draft)
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .font(DiiaFont.smallHeading)
            }
        }
        .font(DiiaFont.usual)
        .scrollContentBackground(.hidden)
        .navigationTitle(draft.title)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: pickedPhoto) {
            guard let pickedPhoto,
                  let data = try? await pickedPhoto.loadTransferable(type: Data.self) else { return }
            draft.photoData = data
        }
    }
}

#Preview {
    NavigationStack {
        DocumentEditScreen(document: DiiaDocument.mocks[0])
            .environment(DocumentStore())
    }
}
