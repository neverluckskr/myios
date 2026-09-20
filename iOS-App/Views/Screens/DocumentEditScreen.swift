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

    var body: some View {
        ZStack {
            FormPalette.canvas.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    documentSection
                    photoSection
                    fieldsSection

                    if draft.details != nil {
                        detailsSection
                    }

                    DiiaFormButton(title: "Скинути до початкових даних", destructive: true) {
                        isConfirmingReset = true
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) { saveBar }
        }
        .navigationTitle(draft.title)
        .navigationBarTitleDisplayMode(.inline)
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
        .task(id: pickedPhoto) {
            guard let pickedPhoto,
                  let data = try? await pickedPhoto.loadTransferable(type: Data.self) else { return }
            draft.photoData = data
        }
    }

    // MARK: - Sections

    private var documentSection: some View {
        DiiaFormSection(title: "Документ", icon: "doc.text") {
            DiiaFormField(title: "Назва", text: $draft.title)

            DiiaFormField(title: "Прізвище, імʼя, по батькові", text: $draft.fullName, axis: .vertical)

            DiiaFormField(
                title: "Бігучий рядок",
                text: $draft.tickerText,
                axis: .vertical,
                hint: "Зелена стрічка внизу картки"
            )

            DiiaFormField(
                title: "Дані QR-коду",
                text: optional($draft.qrPayload),
                axis: .vertical,
                hint: "Порожнє поле — код веде на diia.gov.ua"
            )
        }
    }

    private var photoSection: some View {
        DiiaFormSection(title: "Фото", icon: "person.crop.square") {
            HStack(alignment: .top, spacing: 16) {
                DiiaDocPhoto(data: draft.photoData, width: 104)

                VStack(spacing: 10) {
                    PhotosPicker(selection: $pickedPhoto, matching: .images) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 15, weight: .medium))
                            Text(draft.photoData == nil ? "Обрати" : "Замінити")
                                .font(.system(size: 17))
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(FormPalette.inputIdle)
                        .clipShape(Capsule())
                    }

                    if draft.photoData != nil {
                        DiiaFormButton(title: "Прибрати", icon: "trash", destructive: true) {
                            draft.photoData = nil
                            pickedPhoto = nil
                        }
                    }

                    Spacer(minLength: 0)
                }
            }
        }
    }

    private var fieldsSection: some View {
        DiiaFormSection(title: "Поля на картці", icon: "list.bullet") {
            ForEach($draft.fields) { $field in
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Поле \((draft.fields.firstIndex(where: { $0.id == field.id }) ?? 0) + 1)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(FormPalette.caption)

                        Spacer()

                        Button {
                            draft.fields.removeAll { $0.id == field.id }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.black)
                                .frame(width: 28, height: 28)
                                .background(FormPalette.inputIdle)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }

                    DiiaFormField(title: "Підпис", text: $field.label)
                    DiiaFormField(title: "Підпис англійською", text: optional($field.latinLabel))
                    DiiaFormField(title: "Значення", text: $field.value)
                }
                .padding(.bottom, 6)
            }

            DiiaFormButton(title: "Додати поле", icon: "plus") {
                draft.fields.append(DiiaDocumentField(label: "", value: ""))
            }
        }
    }

    private var detailsSection: some View {
        DiiaFormSection(title: "Повна інформація", icon: "text.book.closed") {
            detailField("ПІБ латиницею", \.latinName)
            detailField("Стать", \.sex)
            detailField("Стать латиницею", \.sexLatin)
            detailField("РНОКПП (ІПН)", \.taxNumber)
            detailField("Документ, що посвідчує особу", \.identityDocument)
            detailField("Номер документа", \.identityDocumentNumber)
            detailField("Місце проживання", \.residence, axis: .vertical)
        }
    }

    private var saveBar: some View {
        DiiaFormButton(title: "Зберегти", filled: true) {
            store.update(draft)
            dismiss()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    // MARK: - Bindings

    private func detailField(
        _ title: String,
        _ path: WritableKeyPath<DiiaDocumentDetails, String>,
        axis: Axis = .horizontal
    ) -> some View {
        DiiaFormField(
            title: title,
            text: Binding(
                get: { draft.details?[keyPath: path] ?? "" },
                set: { draft.details?[keyPath: path] = $0 }
            ),
            axis: axis
        )
    }

    private func optional(_ source: Binding<String?>) -> Binding<String> {
        Binding(
            get: { source.wrappedValue ?? "" },
            set: { source.wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }
}

#Preview {
    NavigationStack {
        DocumentEditScreen(document: DiiaDocument.mocks[0])
            .environment(DocumentStore())
    }
}
