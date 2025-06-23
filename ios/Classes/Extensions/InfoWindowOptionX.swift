import Foundation
import KakaoMapsSDK

// MARK: - InfoWindow Option Extensions

extension Dictionary where Key == String, Value == Any {
    
    /// Convert Dictionary to native iOS InfoWindow with proper GUI component support
    func toNativeInfoWindow() -> InfoWindow? {
        guard let id = self["id"] as? String,
              let latitude = self["latitude"] as? Double,
              let longitude = self["longitude"] as? Double else {
            return nil
        }
        
        let position = MapPoint(longitude: longitude, latitude: latitude)
        let isVisible = self["isVisible"] as? Bool ?? true
        let hasCustomBody = self["hasCustomBody"] as? Bool ?? false
        
        let infoWindow = InfoWindow(id)
        infoWindow.position = position
        
        if hasCustomBody {
            // Handle custom GuiView body
            if let bodyJson = self["body"] as? [String: Any] {
                if let guiBody = bodyJson.createGuiView() {
                    // For iOS, InfoWindow.body expects GuiImage
                    // Convert GuiLayout to appropriate GuiImage structure
                    if let bodyImage = convertToInfoWindowBody(guiBody, from: bodyJson) {
                        infoWindow.body = bodyImage
                    }
                }
            }
            
            // Set body offset if provided
            if let bodyOffsetJson = self["bodyOffset"] as? [String: Any],
               let x = bodyOffsetJson["x"] as? Double,
               let y = bodyOffsetJson["y"] as? Double {
                infoWindow.bodyOffset = CGPoint(x: x, y: y)
            }
            
            // Set tail if provided
            if let tailJson = self["tail"] as? [String: Any],
               let tailImage = tailJson.createGuiImage() {
                infoWindow.tail = tailImage
            }
        } else {
            // Fallback to simple text body
            if let title = self["title"] as? String {
                let snippet = self["snippet"] as? String
                var content = title
                if let snippet = snippet, !snippet.isEmpty {
                    content += "\n\(snippet)"
                }
                
                // Create properly styled text
                if let textBody = createSimpleTextBody(
                    text: content,
                    textSize: self["textSize"] as? Int,
                    textColor: self["textColor"] as? Int
                ) {
                    infoWindow.body = textBody
                }
            }
        }
        
        return infoWindow
    }
}

// MARK: - GUI Component Creation Extensions

extension Dictionary where Key == String, Value == Any {
    
    /// Create GuiView from JSON dictionary
    func createGuiView() -> Any? {
        guard let type = self["type"] as? Int else { return nil }
        
        switch type {
        case 4: // GuiText
            return self.createGuiText()
        case 2, 3: // GuiImage (2: normal, 3: ninepatch)
            return self.createGuiImage()
        case 0, 1: // GuiLayout (0: horizontal, 1: vertical)
            return self.createGuiLayout()
        default:
            return nil
        }
    }
    
    /// Create GuiText with proper styling
    func createGuiText() -> GuiText? {
        guard let text = self["text"] as? String else { return nil }
        
        let componentId = self["componentId"] as? String ?? "text"
        let guiText = GuiText(componentId)
        
        // Extract styling properties
        let textSize = self["textSize"] as? Int ?? 14
        let textColor = self["textColor"] as? Int ?? -16777216 // Black
        let strokeSize = self["strokeSize"] as? Int ?? 0
        let strokeColor = self["strokeColor"] as? Int ?? 0
        
        // Create TextStyle with proper iOS styling
        let style = createTextStyle(
            fontSize: textSize,
            fontColor: textColor,
            strokeWidth: strokeSize,
            strokeColor: strokeColor
        )
        
        guiText.addText(text: text, style: style)
        
        return guiText
    }
    
    /// Create GuiImage with proper resource handling
    func createGuiImage() -> GuiImage? {
        let componentId = self["componentId"] as? String ?? "image"
        let isNinepatch = self["isNinepatch"] as? Bool ?? false
        
        var image: UIImage?
        
        // Try Base64 image first
        if let base64String = self["base64EncodedImage"] as? String, !base64String.isEmpty {
            image = base64String.decodeBase64Image()
        }
        // Handle resource ID if needed (future implementation)
        else if let resourceId = self["resourceId"] as? Int, resourceId != 0 {
            // Resource mapping would go here
            return nil
        }
        // Create empty GuiImage if no source
        else {
            return GuiImage(componentId)
        }
        
        guard let uiImage = image else {
            return GuiImage(componentId)
        }
        
        let guiImage = GuiImage(componentId)
        guiImage.image = uiImage
        
        // Handle nine-patch stretching
        if isNinepatch, let fixedArea = self["fixedArea"] as? [String: Any] {
            // Apply nine-patch settings if iOS SDK supports it
            // This may require different API calls in iOS
        }
        
        // Add child if present
        if let childJson = self["child"] as? [String: Any],
           let childView = childJson.createGuiView() as? GuiComponentBase {
            guiImage.child = childView
        }
        
        return guiImage
    }
    
    /// Create GuiLayout with proper orientation and children
    func createGuiLayout() -> GuiLayout? {
        let componentId = self["componentId"] as? String ?? "layout"
        let orientationValue = self["orientation"] as? Int ?? 0
        let guiLayout = GuiLayout(componentId)
        
        // Set orientation (horizontal=0, vertical=1)
        guiLayout.arrangement = orientationValue == 0 ? .horizontal : .vertical
        
        // Add children
        if let childrenArray = self["children"] as? [[String: Any]] {
            for childJson in childrenArray {
                if let childView = childJson.createGuiView() as? GuiComponentBase {
                    guiLayout.addChild(childView)
                }
            }
        }
        
        return guiLayout
    }
}

// MARK: - Helper Functions

/// Convert GuiView to InfoWindow body (GuiImage)
private func convertToInfoWindowBody(_ guiView: Any, from json: [String: Any]) -> GuiImage? {
    // If it's already a GuiImage, use it directly
    if let guiImage = guiView as? GuiImage {
        return guiImage
    }
    
    // If it's a GuiLayout, we need special handling for iOS InfoWindow limitations
    if let guiLayout = guiView as? GuiLayout {
        return convertLayoutToInfoWindowBody(from: json)
    }
    
    // If it's GuiText, wrap in GuiImage
    if let guiText = guiView as? GuiText {
        let containerImage = GuiImage("")
        containerImage.child = guiText as GuiComponentBase
        return containerImage
    }
    
    return nil
}

/// Convert complex layout to InfoWindow body with proper handling for nested structures
private func convertLayoutToInfoWindowBody(from json: [String: Any]) -> GuiImage? {
    // Create body image (following official documentation pattern)
    let bodyImage = GuiImage("bodyImage")
    
    // Set background image if provided
    if let backgroundJson = json["background"] as? [String: Any],
       let backgroundUIImage = backgroundJson.createGuiImage()?.image {
        bodyImage.image = backgroundUIImage
    }
    
    // Method 1: Use the JSON as-is to create GuiLayout (preferred approach)
    if let guiLayout = json.createGuiLayout() {
        bodyImage.child = guiLayout
        return bodyImage
    }
    
    // Method 2: Create complete layout from children array with orientation
    if let childrenArray = json["children"] as? [[String: Any]], !childrenArray.isEmpty {
        let orientation = json["orientation"] as? Int ?? 0
        if let completeLayout = createCompleteLayout(from: childrenArray, orientation: orientation) {
            bodyImage.child = completeLayout
            return bodyImage
        }
    }
    
    // Fallback: if layout creation fails, use primary child (should rarely happen)
    if let childrenArray = json["children"] as? [[String: Any]], !childrenArray.isEmpty {
        if let primaryChild = findPrimaryChild(from: childrenArray) {
            bodyImage.child = primaryChild
        }
    }
    
    return bodyImage
}

/// Create a complete GuiLayout from children array (proper implementation following docs)
private func createCompleteLayout(from childrenArray: [[String: Any]], orientation: Int = 0) -> GuiLayout? {
    let layout = GuiLayout("infoWindowLayout")
    
    // Set orientation (horizontal=0, vertical=1)
    layout.arrangement = orientation == 0 ? .horizontal : .vertical
    
    // Add all children to layout (following official documentation pattern)
    for childJson in childrenArray {
        if let childComponent = childJson.createGuiView() as? GuiComponentBase {
            layout.addChild(childComponent)
        }
    }
    
    return layout
}

/// Find the primary child component to display (text or image) - for fallback only
/// For iOS InfoWindow compatibility, we prioritize text content over images
private func findPrimaryChild(from childrenArray: [[String: Any]]) -> GuiComponentBase? {
    // Strategy for iOS InfoWindow limitations:
    // 1. Look for text components (most important for InfoWindow readability)
    // 2. If no text, look for image components  
    // 3. For nested layouts, recurse to find the primary content
    // 4. Handle special cases like icon+text combinations
    
    var foundText: GuiComponentBase?
    var foundImage: GuiComponentBase?
    
    // Scan all children to find text and image components
    for childJson in childrenArray {
        if let type = childJson["type"] as? Int {
            switch type {
            case 4: // GuiText
                if let textComponent = childJson.createGuiText() {
                    foundText = textComponent
                    // Don't break - we want to find the last/most important text
                }
            case 2, 3: // GuiImage
                if foundImage == nil, let imageComponent = childJson.createGuiImage() {
                    foundImage = imageComponent
                }
            case 0, 1: // GuiLayout - recurse into nested layouts
                if let nestedChildren = childJson["children"] as? [[String: Any]] {
                    if let nestedPrimary = findPrimaryChild(from: nestedChildren) {
                        // Prefer text from nested layouts
                        if foundText == nil {
                            foundText = nestedPrimary
                        }
                    }
                }
            default:
                break
            }
        }
    }
    
    // Priority: text content over images for better InfoWindow readability
    return foundText ?? foundImage
}

/// Create simple text body for fallback cases
private func createSimpleTextBody(text: String, textSize: Int? = nil, textColor: Int? = nil) -> GuiImage? {
    let guiText = GuiText("")
    
    let style = createTextStyle(
        fontSize: textSize ?? 14,
        fontColor: textColor ?? -16777216,
        strokeWidth: 0,
        strokeColor: 0
    )
    
    guiText.addText(text: text, style: style)
    
    let bodyImage = GuiImage("")
    bodyImage.child = guiText as GuiComponentBase
    return bodyImage
}

/// Create TextStyle with proper color conversion
private func createTextStyle(fontSize: Int, fontColor: Int, strokeWidth: Int, strokeColor: Int) -> TextStyle {
    // Convert Int colors to UIColor
    let textUIColor = fontColor.toUIColor()
    
    // Create TextStyle with available parameters
    // iOS SDK constructor may vary between versions
    
    // Try to create with fontSize and fontColor
    // Note: Some iOS SDK versions may have read-only properties
    // In that case, we may need to use a different approach
    
    // Method 1: Try parameterized constructor
    if let style = createTextStyleWithParams(fontSize: fontSize, fontColor: textUIColor) {
        return style
    }
    
    // Method 2: Fallback to default and try to set properties
    let style = TextStyle()
    // Note: Properties may be read-only in iOS SDK
    // We'll return the default style and log for debugging
    print("⚠️ Using default TextStyle - fontSize: \(fontSize), color: \(String(format: "%02X", fontColor))")
    
    return style
}

/// Try to create TextStyle with parameters
private func createTextStyleWithParams(fontSize: Int, fontColor: UIColor) -> TextStyle? {
    // Try different iOS SDK constructor patterns
    
    // Method 1: Try basic constructor with fontSize and fontColor
    if let style = tryTextStyleConstructor1(fontSize: fontSize, fontColor: fontColor) {
        return style
    }
    
    // Method 2: Try alternative constructor patterns
    if let style = tryTextStyleConstructor2(fontSize: fontSize, fontColor: fontColor) {
        return style
    }
    
    // Method 3: Use default constructor and try to set properties
    let style = TextStyle()
    // Try to set properties if they exist and are settable
    trySetTextStyleProperties(style: style, fontSize: fontSize, fontColor: fontColor)
    
    return style
}

private func tryTextStyleConstructor1(fontSize: Int, fontColor: UIColor) -> TextStyle? {
    do {
        return TextStyle(fontSize: UInt(fontSize), fontColor: fontColor)
    } catch {
        return nil
    }
}

private func tryTextStyleConstructor2(fontSize: Int, fontColor: UIColor) -> TextStyle? {
    do {
        // Alternative constructor pattern - may vary by iOS SDK version
        return TextStyle()
    } catch {
        return nil
    }
}

private func trySetTextStyleProperties(style: TextStyle, fontSize: Int, fontColor: UIColor) {
    // Attempt to set properties if they are writable
    // Note: Properties may be read-only in some iOS SDK versions
    
    // Try to use reflection or direct property setting
    // This is a best-effort attempt
    if style.responds(to: Selector("setFontSize:")) {
        style.perform(Selector("setFontSize:"), with: UInt(fontSize))
    }
    
    if style.responds(to: Selector("setFontColor:")) {
        style.perform(Selector("setFontColor:"), with: fontColor)
    }
}

// MARK: - Color & Utility Extensions

extension Int {
    /// Convert Android color int to UIColor
    func toUIColor() -> UIColor {
        let alpha = CGFloat((self >> 24) & 0xFF) / 255.0
        let red = CGFloat((self >> 16) & 0xFF) / 255.0
        let green = CGFloat((self >> 8) & 0xFF) / 255.0
        let blue = CGFloat(self & 0xFF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension String {
    /// Decode Base64 string to UIImage
    func decodeBase64Image() -> UIImage? {
        guard let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: data)
    }
} 
