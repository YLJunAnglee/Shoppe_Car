import Foundation

/// 启动页ViewModel
@MainActor
class LaunchScreenViewModel {
    // MARK: - 状态回调
    var onEnterButtonTapped: (() -> Void)?
    var onAnimationComplete: (() -> Void)?

    // MARK: - 业务逻辑

    /// 处理进入按钮点击
    func handleEnterButtonTap() {
        // 可以在这里添加额外的逻辑，如数据分析等
        onEnterButtonTapped?()
    }

    /// 检查是否为首次启动
    func checkFirstLaunch() -> Bool {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")

        if !hasLaunchedBefore {
            // 标记为已启动过
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            return true
        }

        return false
    }

    /// 准备页面数据（如果有的话）
    func preparePageData() {
        // 这里可以准备页面需要的数据
        // 例如：加载配置、检查网络状态等
    }

    /// 开始入场动画
    func startEntranceAnimation(completion: @escaping () -> Void) {
        // 模拟动画完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion()
        }
    }

    // MARK: - 页面状态管理

    /// 页面显示状态
    var isShowing: Bool = false

    /// 进入应用主页面
    func navigateToMainApp() {
        // 这里不直接处理导航，通过回调通知ViewController
        onEnterButtonTapped?()
    }
}