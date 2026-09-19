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
    /// Code 128 accepts ASCII only; digits keep it readable under the barcode.
    var barcodeValue: String?

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
                DiiaDocumentField(label: "Дата народження:", value: "09.03.1814"),
                DiiaDocumentField(label: "РНОКПП:", value: "1234567890")
            ]
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
