import UIKit

enum AppColors {
    // 主色调 - 从Figma设计提取
    static let primary = UIColor(hex: "#5F33E1")        // 紫色 (Figma Color/Primary)
    static let secondary = UIColor(hex: "#6E6A7C")      // 灰色 (Figma Color/Secondary)
    static let accent = UIColor(hex: "#FF6B6B")         // 红色 (保留)

    // 背景色
    static let background = UIColor.white               // 白色背景 (Figma bg-white)
    static let surface = UIColor.white                  // 表面色

    // 文本色
    static let textPrimary = UIColor(hex: "#24252C")    // 黑色 (Figma Color/Black)
    static let textSecondary = UIColor(hex: "#6E6A7C")  // 灰色 (Figma Color/Secondary)
    static let textDisabled = UIColor(hex: "#B2BEC3")   // 浅灰色

    // 状态色
    static let success = UIColor(hex: "#00B894")        // 绿色
    static let warning = UIColor(hex: "#FDCB6E")        // 黄色
    static let error = UIColor(hex: "#D63031")          // 红色
    static let info = UIColor(hex: "#0984E3")           // 信息蓝

    // 中性色
    static let gray50 = UIColor(hex: "#F8F9FA")
    static let gray100 = UIColor(hex: "#F1F3F5")
    static let gray200 = UIColor(hex: "#E9ECEF")
    static let gray300 = UIColor(hex: "#DEE2E6")
    static let gray400 = UIColor(hex: "#CED4DA")
    static let gray500 = UIColor(hex: "#ADB5BD")
    static let gray600 = UIColor(hex: "#6C757D")
    static let gray700 = UIColor(hex: "#495057")
    static let gray800 = UIColor(hex: "#343A40")
    static let gray900 = UIColor(hex: "#212529")

    // 透明度辅助
    static func withAlpha(_ color: UIColor, alpha: CGFloat) -> UIColor {
        return color.withAlphaComponent(alpha)
    }
}