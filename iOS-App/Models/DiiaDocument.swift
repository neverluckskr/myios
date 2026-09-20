import Foundation

struct DiiaDocumentField: Codable, Identifiable, Equatable {
    var id = UUID()
    var label: String
    var value: String
    /// Shown greyed under the label on the full-information sheet only.
    var latinLabel: String?
}

/// Extra data shown only on the full-information sheet. Everything here is
/// additional to the card — the card's own fields are reused, not repeated.
struct DiiaDocumentDetails: Codable, Equatable {
    var latinName: String
    var sex: String
    var sexLatin: String
    var taxNumber: String
    var identityDocument: String
    var identityDocumentNumber: String
    var residence: String
}

struct DiiaDocument: Codable, Identifiable, Equatable {
    var id = UUID()
    var title: String
    var fullName: String
    var tickerText: String
    var fields: [DiiaDocumentField]
    var photoData: Data?
    /// Encoded on the back of the card. Falls back to a generated link when empty.
    var qrPayload: String?
    var details: DiiaDocumentDetails?

    static let wartimeTicker = """
        Документ діє під час воєнного стану. \
        Ой у лузі червона калина похилилася, \
        чогось наша славна Україна зажурилася, \
        а ми тую червону калину підіймемо, \
        а ми нашу славну Україну, гей-гей, розвеселимо!
        """

    static let mocks: [DiiaDocument] = [
        DiiaDocument(
            title: "єДокумент",
            fullName: "ШЕВЧЕНКО ТАРАС ГРИГОРОВИЧ",
            tickerText: wartimeTicker,
            fields: [
                DiiaDocumentField(label: "Дата народження:", value: "09.03.1814", latinLabel: "Date of birth"),
                DiiaDocumentField(label: "РНОКПП:", value: "1234567890", latinLabel: "Tax number")
            ],
            details: DiiaDocumentDetails(
                latinName: "SHEVCHENKO TARAS",
                sex: "Ч",
                sexLatin: "M",
                taxNumber: "1234567890",
                identityDocument: "Паспорт громадянина України",
                identityDocumentNumber: "001234567",
                residence: "UA, обл. Київська обл., м. Київ, вул./просп. вул. Хрещатик, буд. 1, кв. 1"
            )
        ),
        DiiaDocument(
            title: "Паспорт громадянина України",
            fullName: "ШЕВЧЕНКО ТАРАС ГРИГОРОВИЧ",
            tickerText: wartimeTicker,
            fields: [
                DiiaDocumentField(label: "Номер:", value: "001234567"),
                DiiaDocumentField(label: "Дата видачі:", value: "12.05.2020")
            ]
        ),
        DiiaDocument(
            title: "Посвідчення водія",
            fullName: "ШЕВЧЕНКО ТАРАС ГРИГОРОВИЧ",
            tickerText: wartimeTicker,
            fields: [
                DiiaDocumentField(label: "Категорії:", value: "B, C"),
                DiiaDocumentField(label: "Дійсне до:", value: "01.01.2035")
            ]
        )
    ]
}
