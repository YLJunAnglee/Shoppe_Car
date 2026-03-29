import UIKit
import SnapKit

final class HomeViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Home"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = AppColors.textPrimary
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "当前是已登录态首页占位页。拿到首页 Figma 导出后，可以直接替换这里。"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = AppColors.textSecondary
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

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
        title = "Home"
        view.backgroundColor = .white

        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().inset(24)
        }

        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(28)
            make.centerX.equalToSuperview()
        }
    }

    private func setupActions() {
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }

    @objc private func logoutTapped() {
        SessionManager.shared.isLoggedIn = false
        (view.window?.windowScene?.delegate as? SceneDelegate)?.reloadRootViewController()
    }
}
