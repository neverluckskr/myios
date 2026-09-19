import UIKit
import CoreImage.CIFilterBuiltins

enum QRCodeGenerator {
    private static let context = CIContext()
    private static var cache: [String: UIImage] = [:]

    static func image(from string: String) -> UIImage? {
        if let cached = cache[string] { return cached }

        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let output = filter.outputImage else { return nil }
        let upscaled = output.transformed(by: CGAffineTransform(scaleX: 12, y: 12))
        guard let cgImage = context.createCGImage(upscaled, from: upscaled.extent) else { return nil }

        let image = UIImage(cgImage: cgImage)
        cache[string] = image
        return image
    }
}
