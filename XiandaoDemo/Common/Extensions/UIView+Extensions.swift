import UIKit

extension UIColor {
    /// 通过十六进制字符串创建UIColor
    /// - Parameters:
    ///   - hex: 十六进制字符串，支持格式：#RGB、#ARGB、#RRGGBB、#AARRGGBB
    ///   - alpha: 透明度（0-1），如果hex中包含透明度，此参数将被忽略
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        // 移除#前缀
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }

        // 检查字符串长度
        let length = hexString.count

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var finalAlpha: CGFloat = alpha

        switch length {
        case 3: // RGB (12-bit)
            red = CGFloat((rgbValue & 0xF00) >> 8) / 15.0
            green = CGFloat((rgbValue & 0x0F0) >> 4) / 15.0
            blue = CGFloat(rgbValue & 0x00F) / 15.0
        case 4: // ARGB (16-bit)
            finalAlpha = CGFloat((rgbValue & 0xF000) >> 12) / 15.0
            red = CGFloat((rgbValue & 0x0F00) >> 8) / 15.0
            green = CGFloat((rgbValue & 0x00F0) >> 4) / 15.0
            blue = CGFloat(rgbValue & 0x000F) / 15.0
        case 6: // RRGGBB (24-bit)
            red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        case 8: // AARRGGBB (32-bit)
            finalAlpha = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            red = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            green = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            blue = CGFloat(rgbValue & 0x000000FF) / 255.0
        default:
            // 默认返回黑色
            red = 0; green = 0; blue = 0
        }

        self.init(red: red, green: green, blue: blue, alpha: finalAlpha)
    }

    /// 通过RGB值创建UIColor
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
}

extension UIView {
    /// 添加圆角
    func roundCorners(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }

    /// 添加边框
    func addBorder(color: UIColor, width: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }

    /// 添加阴影
    func addShadow(color: UIColor = .black,
                   opacity: Float = 0.1,
                   offset: CGSize = .zero,
                   radius: CGFloat = 4) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
}