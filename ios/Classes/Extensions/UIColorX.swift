import Foundation
import UIKit

/// Extension for UIColor to handle Android color format conversion
extension UIColor {
    /// Create UIColor from ARGB integer value (Android format)
    /// - Parameter argb: Integer value representing color in Android ARGB format
    /// - Returns: UIColor instance with proper RGBA values
    static func fromArgb(_ argb: Int) -> UIColor {
        // Handle negative values (which represent alpha channel in Android)
        let alpha: CGFloat
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        
        if argb < 0 {
            // Negative values mean alpha channel is set
            let unsignedArgb = UInt32(bitPattern: Int32(argb))
            alpha = CGFloat((unsignedArgb >> 24) & 0xFF) / 255.0
            red = CGFloat((unsignedArgb >> 16) & 0xFF) / 255.0
            green = CGFloat((unsignedArgb >> 8) & 0xFF) / 255.0
            blue = CGFloat(unsignedArgb & 0xFF) / 255.0
        } else {
            alpha = CGFloat((argb >> 24) & 0xFF) / 255.0
            red = CGFloat((argb >> 16) & 0xFF) / 255.0
            green = CGFloat((argb >> 8) & 0xFF) / 255.0
            blue = CGFloat(argb & 0xFF) / 255.0
        }
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha == 0 && argb != 0 ? 1.0 : alpha)
    }
} 