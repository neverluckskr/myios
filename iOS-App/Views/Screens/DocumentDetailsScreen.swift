import SwiftUI

/// design_system_code: the constructor body Diia builds for "Повна інформація"
struct DocumentDetailsScreen: View {
    let document: DiiaDocument

    private static let blockSpacing: CGFloat = 16
    private static let sidePadding: CGFloat = 16
    /// Clears the sheet's drag indicator before the title starts.
    private static let titleTopPadding: CGFloat = 40

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text(document.title)
                    .font(DiiaFont.main(size: 19))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, Self.titleTopPadding)
                    .padding(.bottom, 24)

                DiiaTicker(text: document.tickerText)

                VStack(spacing: Self.blockSpacing) {
                    identityBlock

                    if let details = document.details {
                        personalBlock(details)
                        residenceBlock(details)
                    }

                    qrBlock
                }
                .padding(.horizontal, Self.sidePadding)
                .padding(.vertical, 24)
            }
        }
        .background(DiiaColors.detailsBackground)
    }

    /// With details present the later blocks carry the rest, so this column
    /// shows only the leading field — the original keeps just the birth date
    /// beside the photo.
    private var identityFields: [DiiaDocumentField] {
        document.details == nil ? document.fields : Array(document.fields.prefix(1))
    }

    // MARK: - Blocks

    private var identityBlock: some View {
        InfoBlock {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.fullName)
                        .font(DiiaFont.main(.bold, size: 19))
                        .foregroundStyle(.black)

                    if let latin = document.details?.latinName, !latin.isEmpty {
                        Text(latin)
                            .font(DiiaFont.main(.bold, size: 14))
                            .foregroundStyle(DiiaColors.secondaryText)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)

                HStack(alignment: .top, spacing: DiiaLayout.columnSpacing) {
                    DiiaDocPhoto(data: document.photoData, width: DiiaLayout.detailsColumnWidth)

                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(identityFields) { field in
                            VerticalItem(
                                label: field.label,
                                latin: field.latinLabel,
                                value: field.value
                            )
                        }
                    }
                    .frame(width: DiiaLayout.detailsColumnWidth, alignment: .leading)
                }
            }
        }
    }

    private func personalBlock(_ details: DiiaDocumentDetails) -> some View {
        InfoBlock {
            VStack(alignment: .leading, spacing: 20) {
                HorizontalItem(
                    label: "Стать:",
                    latinLabel: "Sex",
                    value: details.sex,
                    latinValue: details.sexLatin
                )

                HorizontalItem(
                    label: "РНОКПП (ІПН):",
                    latinLabel: nil,
                    value: details.taxNumber,
                    latinValue: nil,
                    copyable: true
                )

                VerticalItem(
                    label: "Документ, що посвідчує особу:",
                    latin: nil,
                    value: details.identityDocument + "\n" + details.identityDocumentNumber
                )
            }
        }
    }

    private func residenceBlock(_ details: DiiaDocumentDetails) -> some View {
        InfoBlock {
            VerticalItem(
                label: "Місце проживання зазначене в банку:",
                latin: nil,
                value: details.residence
            )
        }
    }

    private var qrBlock: some View {
        InfoBlock {
            DocumentQRCode(document: document, side: DiiaLayout.detailsBlockWidth)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
        }
    }
}

// MARK: - Pieces

/// design_system_code: tableBlockOrg
private struct InfoBlock<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

/// design_system_code: tableItemVerticalMlc
private struct VerticalItem: View {
    let label: String
    let latin: String?
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(DiiaFont.bigText)
                .foregroundStyle(.black)

            if let latin, !latin.isEmpty {
                Text(latin)
                    .font(DiiaFont.bigText)
                    .foregroundStyle(DiiaColors.secondaryText)
            }

            Text(value)
                .font(DiiaFont.bigText)
                .foregroundStyle(.black)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

/// design_system_code: tableItemHorizontalMlc — label takes half the width.
private struct HorizontalItem: View {
    let label: String
    let latinLabel: String?
    let value: String
    let latinValue: String?
    var copyable = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            column(label, latin: latinLabel)
                .frame(maxWidth: .infinity, alignment: .leading)

            column(value, latin: latinValue)
                .frame(maxWidth: .infinity, alignment: .leading)

            if copyable {
                Button {
                    UIPasteboard.general.string = value
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } label: {
                    Image("DS_copy")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Скопіювати")
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func column(_ text: String, latin: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text)
                .font(DiiaFont.bigText)
                .foregroundStyle(.black)

            if let latin, !latin.isEmpty {
                Text(latin)
                    .font(DiiaFont.bigText)
                    .foregroundStyle(DiiaColors.secondaryText)
            }
        }
    }
}

#Preview {
    DocumentDetailsScreen(document: DiiaDocument.mocks[0])
}
