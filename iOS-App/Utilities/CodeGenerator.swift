import UIKit
import CoreImage.CIFilterBuiltins

enum CodeGenerator {
    private static let context = CIContext()
    private static var cache: [String: UIImage] = [:]

    static func qr(from string: String) -> UIImage? {
        render(key: "qr:" + string) {
            let filter = CIFilter.qrCodeGenerator()
            filter.message = Data(string.utf8)
            filter.correctionLevel = "M"
            return filter.outputImage
        }
    }

    static func barcode(from string: String) -> UIImage? {
        render(key: "barcode:" + string) {
            let filter = CIFilter.code128BarcodeGenerator()
            filter.message = Data(string.utf8)
            filter.quietSpace = 3
            return filter.outputImage
        }
    }

    private static func render(key: String, _ make: () -> CIImage?) -> UIImage? {
        if let cached = cache[key] { return cached }

        guard let output = make() else { return nil }
        let upscaled = output.transformed(by: CGAffineTransform(scaleX: 12, y: 12))
        guard let cgImage = context.createCGImage(upscaled, from: upscaled.extent) else { return nil }

        let image = UIImage(cgImage: cgImage)
        cache[key] = image
        return image
    }
}
