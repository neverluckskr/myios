import SwiftUI
import PhotosUI

struct DocumentEditScreen: View {
    @Environment(DocumentStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: DiiaDocument
    @State private var pickedPhoto: PhotosPickerItem?
    @State private var isConfirmingReset = false

    init(document: DiiaDocument) {
        _draft = State(initialValue: document)
    }

    private func detailField(
        _ title: String,
        _ path: WritableKeyPath<DiiaDocumentDetails, String>,
        multiline: Bool = false
    ) -> some View {
        TextField(title, text: Binding(
            get: { draft.details?[keyPath: path] ?? "" },
            set: { draft.details?[keyPath: path] = $0 }
        ), axis: multiline ? .vertical : .horizontal)
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

            if draft.details != nil {
                Section("Повна інформація") {
                    detailField("ПІБ латиницею", \.latinName)
                    detailField("Стать", \.sex)
                    detailField("Стать латиницею", \.sexLatin)
                    detailField("РНОКПП (ІПН)", \.taxNumber)
                    detailField("Документ, що посвідчує особу", \.identityDocument)
                    detailField("Номер документа", \.identityDocumentNumber)
                    detailField("Місце проживання", \.residence, multiline: true)
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
                HStack(spacing: 0) {
                    Button("Зберегти") {
                        store.update(draft)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)

                    Divider()

                    Button("Скинути", role: .destructive) {
                        isConfirmingReset = true
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderless)
                .font(DiiaFont.smallHeading)
            } footer: {
                Text("Скидання поверне початкові дані цього документа.")
            }
        }
        .confirmationDialog(
            "Скинути до початкових даних?",
            isPresented: $isConfirmingReset,
            titleVisibility: .visible
        ) {
            Button("Скинути", role: .destructive) {
                if let fresh = store.resetToDefaults(id: draft.id) {
                    draft = fresh
                }
            }
            Button("Скасувати", role: .cancel) {}
        } message: {
            Text("Усі внесені зміни буде втрачено.")
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
