import Foundation

struct DiiaDocumentField: Codable, Identifiable, Equatable {
    var id = UUID()
    var label: String
    var value: String
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

    static let mocks: [DiiaDocument] = [
        DiiaDocument(
            title: "єДокумент",
            fullName: "ШЕВЧЕНКО\nТАРАС\nГРИГОРОВИЧ",
            tickerText: "Ця копія дійсна для пред'явлення",
            fields: [
                DiiaDocumentField(label: "Дата народження:", value: "09.03.1814"),
                DiiaDocumentField(label: "РНОКПП:", value: "1234567890")
            ]
        ),
        DiiaDocument(
            title: "Паспорт громадянина України",
            fullName: "ШЕВЧЕНКО\nТАРАС\nГРИГОРОВИЧ",
            tickerText: "Документ підтверджено в реєстрі",
            fields: [
                DiiaDocumentField(label: "Номер:", value: "001234567"),
                DiiaDocumentField(label: "Дата видачі:", value: "12.05.2020")
            ]
        ),
        DiiaDocument(
            title: "Посвідчення водія",
            fullName: "ШЕВЧЕНКО\nТАРАС\nГРИГОРОВИЧ",
            tickerText: "Дійсне на території України",
            fields: [
                DiiaDocumentField(label: "Категорії:", value: "B, C"),
                DiiaDocumentField(label: "Дійсне до:", value: "01.01.2035")
            ]
        )
    ]
}
