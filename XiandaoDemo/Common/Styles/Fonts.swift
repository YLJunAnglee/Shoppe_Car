import UIKit

enum AppFonts {
    // 标题字体 - Figma设计规格
    static let largeTitle = UIFont.systemFont(ofSize: 34, weight: .bold)
    static let title1 = UIFont.systemFont(ofSize: 28, weight: .bold)
    static let title2 = UIFont.systemFont(ofSize: 22, weight: .semibold)
    static let title3 = UIFont.systemFont(ofSize: 20, weight: .semibold)

    // Figma设计字体
    static let figmaTitle = UIFont.systemFont(ofSize: 24, weight: .semibold) // Lexend Deca Semi Bold 24px
    static let figmaButton = UIFont.systemFont(ofSize: 19, weight: .semibold) // Lexend Deca Semi Bold 19px
    static let figmaBody = UIFont.systemFont(ofSize: 14, weight: .regular) // Lexend Deca Regular 14px

    // 正文字体
    static let body = UIFont.systemFont(ofSize: 17, weight: .regular)
    static let bodyBold = UIFont.systemFont(ofSize: 17, weight: .semibold)
    static let callout = UIFont.systemFont(ofSize: 16, weight: .regular)
    static let subheadline = UIFont.systemFont(ofSize: 15, weight: .regular)

    // 辅助字体
    static let footnote = UIFont.systemFont(ofSize: 13, weight: .regular)
    static let caption1 = UIFont.systemFont(ofSize: 12, weight: .regular)
    static let caption2 = UIFont.systemFont(ofSize: 11, weight: .regular)

    // 自定义字体（待从Figma设计提取）
    static func customFont(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }

    // 动态字体支持
    static func scaledFont(forTextStyle style: UIFont.TextStyle, weight: UIFont.Weight? = nil) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)

        if let weight = weight {
            let traits = [UIFontDescriptor.TraitKey.weight: weight]
            let weightedDescriptor = descriptor.addingAttributes([.traits: traits])
            return metrics.scaledFont(for: UIFont(descriptor: weightedDescriptor, size: descriptor.pointSize))
        } else {
            return metrics.scaledFont(for: UIFont(descriptor: descriptor, size: descriptor.pointSize))
        }
    }
}