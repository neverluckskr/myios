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
            DiiaGradientBackground().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    documentSection
                    photoSection
                    fieldsSection

                    if draft.details != nil {
                        detailsSection
                    }

                    resetButton
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
        .toolbarBackground(.hidden, for: .navigationBar)
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
                DiiaDocPhoto(data: draft.photoData, width: 96)

                VStack(alignment: .leading, spacing: 10) {
                    PhotosPicker(selection: $pickedPhoto, matching: .images) {
                        Label(draft.photoData == nil ? "Обрати фото" : "Замінити", systemImage: "photo")
                            .font(DiiaFont.bigText)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.75))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    if draft.photoData != nil {
                        Button {
                            draft.photoData = nil
                            pickedPhoto = nil
                        } label: {
                            Label("Прибрати", systemImage: "trash")
                                .font(DiiaFont.bigText)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.75))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 0)
                }
            }
        }
    }

    private var fieldsSection: some View {
        DiiaFormSection(title: "Поля на картці", icon: "list.bullet") {
            ForEach($draft.fields) { $field in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Поле \((draft.fields.firstIndex(where: { $0.id == field.id }) ?? 0) + 1)")
                            .font(DiiaFont.smallTitle)
                            .foregroundStyle(DiiaColors.secondaryText)

                        Spacer()

                        Button {
                            draft.fields.removeAll { $0.id == field.id }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Color.black.opacity(0.25))
                        }
                        .buttonStyle(.plain)
                    }

                    DiiaFormField(title: "Підпис", text: $field.label)
                    DiiaFormField(title: "Підпис англійською", text: optional($field.latinLabel))
                    DiiaFormField(title: "Значення", text: $field.value)
                }
                .padding(.bottom, 4)
            }

            Button {
                draft.fields.append(DiiaDocumentField(label: "", value: ""))
            } label: {
                Label("Додати поле", systemImage: "plus")
                    .font(DiiaFont.bigText)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
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

    private var resetButton: some View {
        Button(role: .destructive) {
            isConfirmingReset = true
        } label: {
            Text("Скинути до початкових даних")
                .font(DiiaFont.bigText)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }

    private var saveBar: some View {
        Button {
            store.update(draft)
            dismiss()
        } label: {
            Text("Зберегти")
                .font(DiiaFont.smallHeading)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
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
