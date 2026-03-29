import UIKit
import SnapKit

final class AuthPlaceholderViewController: UIViewController {
    enum Mode {
        case signUp
        case login

        var titleText: String {
            switch self {
            case .signUp:
                return "Get Started"
            case .login:
                return "Log In"
            }
        }

        var descriptionText: String {
            switch self {
            case .signUp:
                return "这里先用占位页承接注册流程。后续拿到注册或 onboarding 的 Figma 节点后，可以直接替换。"
            case .login:
                return "这里先用占位页承接登录流程。点击下面按钮会模拟登录并进入首页。"
            }
        }

        var primaryButtonTitle: String {
            switch self {
            case .signUp:
                return "Continue as Demo User"
            case .login:
                return "Log In and Open Home"
            }
        }
    }

    private let mode: Mode

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let primaryButton = UIButton(type: .system)

    init(mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupUI() {
        title = mode.titleText
        view.backgroundColor = .white

        titleLabel.text = mode.titleText
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#202020")

        descriptionLabel.text = mode.descriptionText
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = UIColor(hex: "#6E6E6E")
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center

        primaryButton.setTitle(mode.primaryButtonTitle, for: .normal)
        primaryButton.backgroundColor = UIColor(hex: "#004CFF")
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        primaryButton.layer.cornerRadius = 14

        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(primaryButton)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(100)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().inset(28)
        }

        primaryButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(36)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }
    }

    private func setupActions() {
        primaryButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
    }

    @objc private func primaryButtonTapped() {
        SessionManager.shared.isLoggedIn = true
        (view.window?.windowScene?.delegate as? SceneDelegate)?.reloadRootViewController()
    }
}
