import UIKit

enum Spacing {
    // 基础间距
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48

    // 特定用途间距
    static let screenPadding: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let buttonHeight: CGFloat = 50
    static let iconSize: CGFloat = 24
}

enum CornerRadius {
    static let small: CGFloat = 4
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
    static let xlarge: CGFloat = 16
    static let circle: CGFloat = .infinity
}

enum AnimationDuration {
    static let fast: TimeInterval = 0.2
    static let normal: TimeInterval = 0.3
    static let slow: TimeInterval = 0.5
}

enum ScreenHeightTier {
    case compact
    case regular
    case expanded

    static func current(for screenHeight: CGFloat) -> ScreenHeightTier {
        switch screenHeight {
        case ..<700:
            return .compact
        case ..<900:
            return .regular
        default:
            return .expanded
        }
    }

    @MainActor
    static func current() -> ScreenHeightTier {
        current(for: UIScreen.main.bounds.height)
    }
}

enum AdaptiveLayout {
    static let referenceScreenHeight: CGFloat = 812

    static func value(
        compact: CGFloat,
        regular: CGFloat,
        expanded: CGFloat,
        for screenHeight: CGFloat
    ) -> CGFloat {
        switch ScreenHeightTier.current(for: screenHeight) {
        case .compact:
            return compact
        case .regular:
            return regular
        case .expanded:
            return expanded
        }
    }

    @MainActor
    static func value(
        compact: CGFloat,
        regular: CGFloat,
        expanded: CGFloat
    ) -> CGFloat {
        value(
            compact: compact,
            regular: regular,
            expanded: expanded,
            for: UIScreen.main.bounds.height
        )
    }

    static func scale(
        _ base: CGFloat,
        for screenHeight: CGFloat,
        minScale: CGFloat = 0.9,
        maxScale: CGFloat = 1.08
    ) -> CGFloat {
        let rawScale = screenHeight / referenceScreenHeight
        let clampedScale = min(max(rawScale, minScale), maxScale)
        return base * clampedScale
    }

    @MainActor
    static func scale(
        _ base: CGFloat,
        minScale: CGFloat = 0.9,
        maxScale: CGFloat = 1.08
    ) -> CGFloat {
        scale(
            base,
            for: UIScreen.main.bounds.height,
            minScale: minScale,
            maxScale: maxScale
        )
    }
}

enum AppConstants {
    // 应用标识
    static let appName = "XiandaoDemo"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"

    // 用户默认值键名
    static let hasLaunchedBeforeKey = "hasLaunchedBefore"
    static let userPreferencesKey = "userPreferences"

    // 其他常量
    static let maxRetryCount = 3
    static let timeoutInterval: TimeInterval = 30
}
