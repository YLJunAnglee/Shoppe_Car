import UIKit
import SnapKit

/// 未登录启动页，对应 Figma `01 Start`
final class LaunchScreenView: UIView {
    private let metrics = LaunchScreenMetrics.current()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        return scrollView
    }()

    private let contentView = UIView()

    private let mainStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        return stackView
    }()

    private let topSpacer = UIView()
    private let buttonSpacer = UIView()
    private let bottomSpacer = UIView()
    private let illustrationWrapper = UIView()
    private let existingAccountWrapper = UIView()
    private let existingAccountContentView = UIView()

    private let illustrationContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.16
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 8
        return view
    }()

    private let illustrationView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "login_icon")
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    private let primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(hex: "#004CFF")
        button.layer.cornerRadius = 16
        button.setTitle("Let's get started", for: .normal)
        button.setTitleColor(UIColor(hex: "#F3F3F3"), for: .normal)
        return button
    }()

    private let existingAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "I already have an account"
        label.textColor = UIColor(hex: "#202020")
        label.font = UIFont(name: "NunitoSans-Light", size: 15) ?? .systemFont(ofSize: 15, weight: .light)
        return label
    }()

    private let existingAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(hex: "#004CFF")
        button.layer.cornerRadius = 15
        let configuration = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        button.setImage(UIImage(systemName: "arrow.right", withConfiguration: configuration), for: .normal)
        button.tintColor = .white
        return button
    }()

    private var contentViewsForAnimation: [UIView] {
        [
            illustrationContainer,
            titleLabel,
            descriptionLabel,
            primaryButton,
            existingAccountContentView
        ]
    }

    var onEnterButtonTapped: (() -> Void)?
    var onExistingAccountTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        applyMetrics()
        setupConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white

        titleLabel.text = "Shoppe"
        titleLabel.textColor = UIColor(hex: "#202020")
        titleLabel.textAlignment = .center

        descriptionLabel.text = "Beautiful eCommerce UI Kit for your online store"
        descriptionLabel.textColor = UIColor(hex: "#202020")
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 2

        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStack)

        mainStack.addArrangedSubview(topSpacer)
        mainStack.addArrangedSubview(illustrationWrapper)
        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(descriptionLabel)
        mainStack.addArrangedSubview(buttonSpacer)
        mainStack.addArrangedSubview(primaryButton)
        mainStack.addArrangedSubview(existingAccountWrapper)
        mainStack.addArrangedSubview(bottomSpacer)

        illustrationWrapper.addSubview(illustrationContainer)
        illustrationContainer.addSubview(illustrationView)

        existingAccountWrapper.addSubview(existingAccountContentView)
        existingAccountContentView.addSubview(existingAccountLabel)
        existingAccountContentView.addSubview(existingAccountButton)
    }

    private func applyMetrics() {
        illustrationContainer.layer.cornerRadius = metrics.illustrationSize / 2
        titleLabel.font = UIFont(name: "Raleway-Bold", size: metrics.titleFontSize) ?? .systemFont(ofSize: metrics.titleFontSize, weight: .bold)
        descriptionLabel.font = UIFont(name: "NunitoSans-Light", size: metrics.descriptionFontSize) ?? .systemFont(ofSize: metrics.descriptionFontSize, weight: .light)
        primaryButton.titleLabel?.font = UIFont(name: "NunitoSans-Light", size: metrics.buttonFontSize) ?? .systemFont(ofSize: metrics.buttonFontSize, weight: .light)
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.safeAreaLayoutGuide.snp.edges)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide.snp.edges)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
            make.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide.snp.height)
        }

        mainStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(metrics.horizontalInset)
            make.trailing.equalToSuperview().inset(metrics.horizontalInset)
            make.top.bottom.equalToSuperview()
        }

        topSpacer.snp.makeConstraints { make in
            make.height.equalTo(metrics.topSpacerHeight).priority(750)
        }

        illustrationWrapper.snp.makeConstraints { make in
            make.height.equalTo(metrics.illustrationSize)
        }

        illustrationContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: metrics.illustrationSize, height: metrics.illustrationSize))
        }

        illustrationView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(metrics.illustrationInset)
        }

        titleLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(metrics.titleHeight)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(metrics.descriptionHorizontalInset)
            make.trailing.equalToSuperview().inset(metrics.descriptionHorizontalInset)
        }

        buttonSpacer.snp.makeConstraints { make in
            make.height.equalTo(metrics.buttonSpacerHeight).priority(750)
        }

        primaryButton.snp.makeConstraints { make in
            make.height.equalTo(metrics.buttonHeight)
        }

        existingAccountWrapper.snp.makeConstraints { make in
            make.height.equalTo(30)
        }

        existingAccountContentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }

        existingAccountLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }

        existingAccountButton.snp.makeConstraints { make in
            make.leading.equalTo(existingAccountLabel.snp.trailing).offset(16)
            make.trailing.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 30, height: 30))
        }

        bottomSpacer.snp.makeConstraints { make in
            make.height.equalTo(metrics.bottomSpacerHeight).priority(750)
        }

        mainStack.setCustomSpacing(metrics.titleTopSpacing, after: illustrationWrapper)
        mainStack.setCustomSpacing(metrics.descriptionTopSpacing, after: titleLabel)
        mainStack.setCustomSpacing(metrics.linkTopSpacing, after: primaryButton)
    }

    private func setupActions() {
        primaryButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
        primaryButton.addTarget(self, action: #selector(primaryButtonTouchDown), for: .touchDown)
        primaryButton.addTarget(self, action: #selector(primaryButtonTouchUp), for: [.touchCancel, .touchUpInside, .touchUpOutside])

        existingAccountButton.addTarget(self, action: #selector(existingAccountButtonTapped), for: .touchUpInside)
    }

    func performEntranceAnimation() {
        contentViewsForAnimation.forEach {
            $0.alpha = 0
            $0.transform = CGAffineTransform(translationX: 0, y: 18)
        }

        for (index, view) in contentViewsForAnimation.enumerated() {
            UIView.animate(
                withDuration: 0.55,
                delay: 0.08 * Double(index),
                options: .curveEaseOut,
                animations: {
                    view.alpha = 1
                    view.transform = .identity
                }
            )
        }
    }

    func updateContent(title: String, description: String, buttonTitle: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        primaryButton.setTitle(buttonTitle, for: .normal)
    }

    @objc private func primaryButtonTapped() {
        animatePrimaryButtonTap()
        onEnterButtonTapped?()
    }

    @objc private func existingAccountButtonTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.existingAccountButton.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.12) {
                self.existingAccountButton.transform = .identity
            }
        }
        onExistingAccountTapped?()
    }

    @objc private func primaryButtonTouchDown() {
        primaryButton.alpha = 0.85
    }

    @objc private func primaryButtonTouchUp() {
        primaryButton.alpha = 1
    }

    private func animatePrimaryButtonTap() {
        UIView.animate(withDuration: 0.1, animations: {
            self.primaryButton.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { _ in
            UIView.animate(withDuration: 0.12) {
                self.primaryButton.transform = .identity
            }
        }
    }
}

private struct LaunchScreenMetrics {
    let horizontalInset: CGFloat
    let topSpacerHeight: CGFloat
    let illustrationSize: CGFloat
    let illustrationInset: CGFloat
    let titleFontSize: CGFloat
    let titleHeight: CGFloat
    let titleTopSpacing: CGFloat
    let descriptionFontSize: CGFloat
    let descriptionTopSpacing: CGFloat
    let descriptionHorizontalInset: CGFloat
    let buttonSpacerHeight: CGFloat
    let buttonHeight: CGFloat
    let buttonFontSize: CGFloat
    let linkTopSpacing: CGFloat
    let bottomSpacerHeight: CGFloat

    static func current(screenHeight: CGFloat) -> LaunchScreenMetrics {
        LaunchScreenMetrics(
            horizontalInset: AdaptiveLayout.value(compact: 20, regular: 20, expanded: 24, for: screenHeight),
            topSpacerHeight: AdaptiveLayout.value(compact: 28, regular: 64, expanded: 88, for: screenHeight),
            illustrationSize: AdaptiveLayout.value(compact: 118, regular: 134, expanded: 144, for: screenHeight),
            illustrationInset: AdaptiveLayout.value(compact: 16, regular: 18, expanded: 20, for: screenHeight),
            titleFontSize: AdaptiveLayout.value(compact: 46, regular: 52, expanded: 56, for: screenHeight),
            titleHeight: AdaptiveLayout.value(compact: 56, regular: 64, expanded: 68, for: screenHeight),
            titleTopSpacing: AdaptiveLayout.value(compact: 20, regular: 24, expanded: 28, for: screenHeight),
            descriptionFontSize: AdaptiveLayout.value(compact: 17, regular: 19, expanded: 20, for: screenHeight),
            descriptionTopSpacing: AdaptiveLayout.value(compact: 14, regular: 18, expanded: 20, for: screenHeight),
            descriptionHorizontalInset: AdaptiveLayout.value(compact: 34, regular: 35, expanded: 48, for: screenHeight),
            buttonSpacerHeight: AdaptiveLayout.value(compact: 56, regular: 96, expanded: 120, for: screenHeight),
            buttonHeight: AdaptiveLayout.value(compact: 58, regular: 61, expanded: 64, for: screenHeight),
            buttonFontSize: AdaptiveLayout.value(compact: 20, regular: 22, expanded: 23, for: screenHeight),
            linkTopSpacing: AdaptiveLayout.value(compact: 16, regular: 18, expanded: 22, for: screenHeight),
            bottomSpacerHeight: AdaptiveLayout.value(compact: 20, regular: 28, expanded: 36, for: screenHeight)
        )
    }

    @MainActor
    static func current() -> LaunchScreenMetrics {
        current(screenHeight: UIScreen.main.bounds.height)
    }
}
