import SwiftUI

struct DocumentsReorderScreen: View {
    @Environment(DocumentStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            DiiaGradientBackground().ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.black)
                        .frame(width: 44, height: 44, alignment: .leading)
                }
                .buttonStyle(.plain)

                Text("Змінити порядок")
                    .font(DiiaFont.main(size: 32))
                    .foregroundStyle(.black)

                List {
                    ForEach(store.documents) { document in
                        Text(document.title)
                            .font(DiiaFont.smallHeading)
                            .foregroundStyle(.black)
                            .padding(.vertical, 12)
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: DiiaLayout.cardCornerRadius, style: .continuous)
                                    .fill(Color.white.opacity(0.4))
                                    .padding(.vertical, 4)
                            )
                            .listRowSeparator(.hidden)
                    }
                    .onMove { source, destination in
                        store.documents.move(fromOffsets: source, toOffset: destination)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .environment(\.editMode, .constant(.active))
            }
            .padding(.horizontal, DiiaLayout.sideSpacing)
            .padding(.top, 8)
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        DocumentsReorderScreen().environment(DocumentStore())
    }
}
