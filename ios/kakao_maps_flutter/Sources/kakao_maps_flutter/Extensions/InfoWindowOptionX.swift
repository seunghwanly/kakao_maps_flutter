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
                    // For iOS, InfoWindow.body expects GuiButton (to enable tap events)
                    // Convert GuiLayout to appropriate GuiButton structure
                    if let bodyButton = convertToInfoWindowBody(guiBody, from: bodyJson) {
                        infoWindow.body = bodyButton
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
               let tailButton = tailJson.createGuiButton() {
                infoWindow.tail = tailButton
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
        case 2, 3: // GuiButton (was GuiImage) - enables tap events
            return self.createGuiButton()
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
        
        // Apply padding if provided
        if let padding = self.createGuiPadding() {
            guiText.padding = padding
        }
        
        // Apply common GUI component properties
        guiText.applyCommonGuiProperties(from: self)
        
        return guiText
    }
    
    /// Create GuiButton (was GuiImage) with proper resource handling and tap capability
    func createGuiButton() -> GuiButton? {
        let componentId = self["componentId"] as? String ?? "button"
        let isNinepatch = self["isNinepatch"] as? Bool ?? false
        
        var image: UIImage?
        
        // Try Base64 image first
        if let base64String = self["base64EncodedImage"] as? String, !base64String.isEmpty {
            image = base64String.decodeBase64Image()
        }
        // Handle resource ID if needed (future implementation)
        else if let resourceId = self["resourceId"] as? Int, resourceId != 0 {
            // Resource mapping would go here
            return GuiButton(componentId)
        }
        // Create empty GuiButton if no source
        else {
            return GuiButton(componentId)
        }
        
        let guiButton = GuiButton(componentId)
        
        // Set the main image
        if let uiImage = image {
            guiButton.image = uiImage
            
            // Optionally set pressed state image (can be same as normal image or customized)
            // For now, use the same image for pressed state
            guiButton.pressedImage = uiImage
        }
        
        // Handle nine-patch stretching
        if isNinepatch, let fixedArea = self["fixedArea"] as? [String: Any] {
            // Apply nine-patch settings if iOS SDK supports it
            // This may require different API calls in iOS
        }
        
        // Apply padding if provided
        if let padding = self.createGuiPadding() {
            guiButton.padding = padding
        }
        
        // Add child if present
        if let childJson = self["child"] as? [String: Any],
           let childView = childJson.createGuiView() as? GuiComponentBase {
            guiButton.child = childView
        }
        
        // Apply common GUI component properties
        guiButton.applyCommonGuiProperties(from: self)
        
        return guiButton
    }
    
    /// Create GuiLayout with proper orientation and children
    func createGuiLayout() -> GuiLayout? {
        let componentId = self["componentId"] as? String ?? "layout"
        let orientationValue = self["orientation"] as? Int ?? 0
        let guiLayout = GuiLayout(componentId)
        
        // Set orientation (horizontal=0, vertical=1)
        guiLayout.arrangement = orientationValue == 0 ? .horizontal : .vertical
        
        // Apply padding if provided
        if let padding = self.createGuiPadding() {
            guiLayout.padding = padding
        }
        
        // Add children
        if let childrenArray = self["children"] as? [[String: Any]] {
            for childJson in childrenArray {
                if let childView = childJson.createGuiView() as? GuiComponentBase {
                    guiLayout.addChild(childView)
                }
            }
        }
        
        // Apply common GUI component properties
        guiLayout.applyCommonGuiProperties(from: self)
        
        return guiLayout
    }
    
    /// Legacy method for backward compatibility - creates GuiButton instead
    func createGuiImage() -> GuiButton? {
        return self.createGuiButton()
    }
    
    /// Create GuiPadding from JSON padding properties
    func createGuiPadding() -> GuiPadding? {
        // Check if any padding properties exist
        let paddingLeft = self["paddingLeft"] as? Int ?? 0
        let paddingTop = self["paddingTop"] as? Int ?? 0
        let paddingRight = self["paddingRight"] as? Int ?? 0
        let paddingBottom = self["paddingBottom"] as? Int ?? 0
        
        // If all padding values are 0, return nil (no padding)
        if paddingLeft == 0 && paddingTop == 0 && paddingRight == 0 && paddingBottom == 0 {
            return nil
        }
        
        // Create GuiPadding with individual values
        return createGuiPaddingWithValues(
            left: paddingLeft,
            top: paddingTop,
            right: paddingRight,
            bottom: paddingBottom
        )
    }
}

// MARK: - Helper Functions

/// Create GuiPadding with specified values
private func createGuiPaddingWithValues(left: Int, top: Int, right: Int, bottom: Int) -> GuiPadding? {
    // Try GuiPadding constructor with individual parameters (iOS SDK pattern)
    do {
        return GuiPadding(left: Int32(left), right: Int32(right), top: Int32(top), bottom: Int32(bottom))
    } catch {
        // Fallback to default constructor
        // GuiPadding creation failed - using default
        return GuiPadding()
    }
}

/// Convert GuiView to InfoWindow body (GuiButton)
private func convertToInfoWindowBody(_ guiView: Any, from json: [String: Any]) -> GuiButton? {
    // If it's already a GuiButton, use it directly
    if let guiButton = guiView as? GuiButton {
        return guiButton
    }
    
    // If it's a GuiLayout, we need special handling for iOS InfoWindow limitations
    if let guiLayout = guiView as? GuiLayout {
        return convertLayoutToInfoWindowBody(from: json)
    }
    
    // If it's GuiText, wrap in GuiButton
    if let guiText = guiView as? GuiText {
        let containerButton = GuiButton("")
        containerButton.child = guiText as GuiComponentBase
        return containerButton
    }
    
    return nil
}

/// Convert complex layout to InfoWindow body with proper handling for nested structures
private func convertLayoutToInfoWindowBody(from json: [String: Any]) -> GuiButton? {
    // Create body button (following official documentation pattern with tap capability)
    let bodyButton = GuiButton("bodyButton")
    
    // Set background image if provided
    if let backgroundJson = json["background"] as? [String: Any],
       let backgroundUIImage = backgroundJson.createGuiButton()?.image {
        bodyButton.image = backgroundUIImage
    }
    
    // Method 1: Use the JSON as-is to create GuiLayout (preferred approach)
    if let guiLayout = json.createGuiLayout() {
        bodyButton.child = guiLayout
        return bodyButton
    }
    
    // Method 2: Create complete layout from children array with orientation
    if let childrenArray = json["children"] as? [[String: Any]], !childrenArray.isEmpty {
        let orientation = json["orientation"] as? Int ?? 0
        if let completeLayout = createCompleteLayout(from: childrenArray, orientation: orientation) {
            bodyButton.child = completeLayout
            return bodyButton
        }
    }
    
    // Fallback: if layout creation fails, use primary child (should rarely happen)
    if let childrenArray = json["children"] as? [[String: Any]], !childrenArray.isEmpty {
        if let primaryChild = findPrimaryChild(from: childrenArray) {
            bodyButton.child = primaryChild
        }
    }
    
    return bodyButton
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
            case 2, 3: // GuiButton
                if foundImage == nil, let imageComponent = childJson.createGuiButton() {
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
private func createSimpleTextBody(text: String, textSize: Int? = nil, textColor: Int? = nil) -> GuiButton? {
    let guiText = GuiText("")
    
    let style = createTextStyle(
        fontSize: textSize ?? 14,
        fontColor: textColor ?? -16777216,
        strokeWidth: 0,
        strokeColor: 0
    )
    
    guiText.addText(text: text, style: style)
    
    let bodyButton = GuiButton("")
    bodyButton.child = guiText as GuiComponentBase
    return bodyButton
}

/// Create TextStyle with proper color conversion
private func createTextStyle(fontSize: Int, fontColor: Int, strokeWidth: Int, strokeColor: Int) -> TextStyle {
    // Convert Int colors to UIColor
    let textUIColor = fontColor.toUIColor()
    
    // Try to create with fontSize and fontColor
    do {
        return TextStyle(fontSize: UInt(fontSize), fontColor: textUIColor)
    } catch {
        // Fallback to default style
        // Using default TextStyle
        return TextStyle()
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

// MARK: - GUI Component Common Properties Extension

extension GuiComponentBase {
    /// Apply common GUI properties from JSON dictionary (following Android patterns)
    func applyCommonGuiProperties(from json: [String: Any]) {
        // Set origin alignment (equivalent to Android setOrigin)
        let verticalOrigin = json["verticalOrigin"] as? Int ?? 2 // Bottom (default)
        let horizontalOrigin = json["horizontalOrigin"] as? Int ?? 1 // Center (default)
        
        if let originAlignment = createGuiAlignment(
            vertical: verticalOrigin,
            horizontal: horizontalOrigin
        ) {
            self.origin = originAlignment
        }
        
        // Set component alignment (equivalent to Android setAlign)
        let verticalAlign = json["verticalAlign"] as? Int ?? 1 // Center (default)
        let horizontalAlign = json["horizontalAlign"] as? Int ?? 1 // Center (default)
        
        if let alignAlignment = createGuiAlignment(
            vertical: verticalAlign,
            horizontal: horizontalAlign
        ) {
            self.align = alignAlignment
        }
        
        // Set tag if present (equivalent to Android setTag)
        // Note: GuiComponentBase may not have tag property in iOS SDK
        // Store tag information for debugging/logging purposes
        if let tag = json["tag"], !(tag is NSNull) {
            // Note: iOS SDK may not support tag property
        }
    }
}

// MARK: - GuiAlignment Creation Helpers

/// Create GuiAlignment from vertical and horizontal alignment values
/// Following Android enum values pattern:
/// Vertical: Top=0, Center=1, Bottom=2
/// Horizontal: Left=0, Center=1, Right=2
private func createGuiAlignment(vertical: Int, horizontal: Int) -> GuiAlignment? {
    // Convert Android enum values to iOS GuiAlignment
    let verticalAlignment = convertVerticalAlignment(vertical)
    let horizontalAlignment = convertHorizontalAlignment(horizontal)
    
    // Try GuiAlignment constructor with proper parameter names
    do {
        return GuiAlignment(vAlign: verticalAlignment, hAlign: horizontalAlignment)
    } catch {
        // Fallback to default alignment
        return GuiAlignment()
    }
}

/// Convert Android vertical alignment values to iOS VerticalAlign enum
private func convertVerticalAlignment(_ value: Int) -> VerticalAlign {
    switch value {
    case 0: return .top
    case 1: return .middle // iOS uses 'middle' instead of 'center' for vertical
    case 2: return .bottom
    default: return .middle // Default to middle
    }
}

/// Convert Android horizontal alignment values to iOS HorizontalAlign enum
private func convertHorizontalAlignment(_ value: Int) -> HorizontalAlign {
    switch value {
    case 0: return .left
    case 1: return .center
    case 2: return .right
    default: return .center // Default to center
    }
} 
