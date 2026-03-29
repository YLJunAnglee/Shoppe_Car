import UIKit

/// 启动页ViewController
class LaunchScreenViewController: UIViewController {
    // MARK: - 属性

    private let launchView = LaunchScreenView()
    private let viewModel = LaunchScreenViewModel()

    // MARK: - 生命周期

    override func loadView() {
        view = launchView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        checkFirstLaunch()
        preparePage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startEntranceAnimation()
    }

    // MARK: - 初始化设置

    private func setupBindings() {
        // ViewModel回调
        viewModel.onEnterButtonTapped = { [weak self] in
            self?.navigateToCreateAccount()
        }

        viewModel.onAnimationComplete = { [weak self] in
            self?.handleAnimationComplete()
        }

        // View回调
        launchView.onEnterButtonTapped = { [weak self] in
            self?.viewModel.handleEnterButtonTap()
        }

        launchView.onExistingAccountTapped = { [weak self] in
            self?.navigateToLogin()
        }
    }

    // MARK: - 业务逻辑

    private func checkFirstLaunch() {
        if viewModel.checkFirstLaunch() {
            // 首次启动的特殊处理
            print("应用首次启动")
            // 可以在这里显示引导页或特殊欢迎信息
        }
    }

    private func preparePage() {
        viewModel.preparePageData()

        // 配置页面内容 - 使用Figma设计中的文本
        launchView.updateContent(
            title: "Shoppe",
            description: "Beautiful eCommerce UI Kit for your online store",
            buttonTitle: "Let's get started"
        )
    }

    private func startEntranceAnimation() {
        // 执行View中的入场动画
        launchView.performEntranceAnimation()

        // 通知ViewModel动画开始
        viewModel.startEntranceAnimation { [weak self] in
            self?.viewModel.onAnimationComplete?()
        }
    }

    private func handleAnimationComplete() {
        // 动画完成后的处理
        print("启动页动画完成")
    }

    // MARK: - 导航

    private func navigateToCreateAccount() {
        navigationController?.pushViewController(
            CreateAccountViewController(),
            animated: true
        )
    }

    private func navigateToLogin() {
        navigationController?.pushViewController(
            AuthPlaceholderViewController(mode: .login),
            animated: true
        )
    }

    // MARK: - 状态处理

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    // MARK: - 内存管理

    deinit {
        print("LaunchScreenViewController deinitialized")
    }
}
