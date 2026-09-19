import UIKit
import CoreImage.CIFilterBuiltins

enum CodeGenerator {
    private static let context = CIContext()
    /// Codes are reissued periodically, so the cache is capped to stop the
    /// retired images piling up.
    private static let cacheLimit = 4
    private static var cache: [String: UIImage] = [:]

    static func qr(from string: String) -> UIImage? {
        if let cached = cache[string] { return cached }

        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let output = filter.outputImage else { return nil }
        let upscaled = output.transformed(by: CGAffineTransform(scaleX: 8, y: 8))
        guard let cgImage = context.createCGImage(upscaled, from: upscaled.extent) else { return nil }

        let image = UIImage(cgImage: cgImage)
        if cache.count >= cacheLimit { cache.removeAll() }
        cache[string] = image
        return image
    }
}
