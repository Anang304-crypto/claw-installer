// QRCodeGenerator — Generate QR codes using CoreImage

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import AppKit

struct QRCodeGenerator {
    
    /// Generate a QR code NSImage from a string
    static func generate(from string: String, size: CGFloat = 200) -> NSImage? {
        // Create QR code filter
        let filter = CIFilter.qrCodeGenerator()
        
        // Set input data
        guard let data = string.data(using: .utf8) else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel") // High error correction
        
        // Get output image
        guard let ciImage = filter.outputImage else { return nil }
        
        // Scale the image
        let scaleX = size / ciImage.extent.width
        let scaleY = size / ciImage.extent.height
        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // Convert to NSImage
        let rep = NSCIImageRep(ciImage: scaledImage)
        let nsImage = NSImage(size: NSSize(width: size, height: size))
        nsImage.addRepresentation(rep)
        
        return nsImage
    }
    
    /// Generate Threads share intent URL
    static func threadsShareURL(text: String, url: String? = nil) -> URL? {
        var components = URLComponents(string: "https://www.threads.net/intent/post")
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "text", value: text))
        
        if let url = url {
            queryItems.append(URLQueryItem(name: "url", value: url))
        }
        
        components?.queryItems = queryItems
        return components?.url
    }
    
    /// Generate Twitter/X share intent URL
    static func twitterShareURL(text: String, url: String? = nil) -> URL? {
        var components = URLComponents(string: "https://twitter.com/intent/tweet")
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "text", value: text))
        
        if let url = url {
            queryItems.append(URLQueryItem(name: "url", value: url))
        }
        
        components?.queryItems = queryItems
        return components?.url
    }
    
    /// Default share message for ClawInstaller
    static var defaultShareText: String {
        "用 ClawInstaller 三分鐘搞定 OpenClaw 安裝！#OpenClaw"
    }
    
    static var defaultShareURL: String {
        "https://github.com/clawinstaller/claw-installer"
    }
}
