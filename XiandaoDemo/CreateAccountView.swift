import UIKit
import SnapKit

final class CreateAccountView: UIView {
    private let metrics = CreateAccountMetrics.current()

    private let backgroundLightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "create_account_bg_light")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let backgroundBlueImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "create_account_bg_blue")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private let contentView = UIView()
    private let titleLabel = UILabel()

    private let uploadPhotoContainer = UIView()

    private let uploadPhotoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        return button
    }()

    private let uploadPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "upload_photo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let emailField = CreateAccountInputField(placeholder: "Email")
    private let passwordField = CreateAccountInputField(
        placeholder: "Password",
        trailingSystemImageName: "eye.slash"
    )
    private let phoneField = CreateAccountPhoneField(placeholder: "Your number")

    private lazy var formStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailField, passwordField, phoneField])
        stackView.axis = .vertical
        stackView.spacing = metrics.formSpacing
        return stackView
    }()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(hex: "#004CFF")
        button.layer.cornerRadius = 16
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor(hex: "#202020"), for: .normal)
        button.alpha = 0.9
        return button
    }()

    var onDoneButtonTapped: (() -> Void)?
    var onCancelButtonTapped: (() -> Void)?
    var onUploadPhotoTapped: (() -> Void)?
    var onEmailChanged: ((String) -> Void)?
    var onPasswordChanged: ((String) -> Void)?
    var onPhoneChanged: ((String) -> Void)?
    private weak var activeInputContainerView: UIView?

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

        addSubview(backgroundLightImageView)
        addSubview(backgroundBlueImageView)
        addSubview(scrollView)

        scrollView.addSubview(contentView)

        titleLabel.numberOfLines = 2
        titleLabel.textColor = UIColor(hex: "#202020")

        contentView.addSubview(titleLabel)
        contentView.addSubview(uploadPhotoContainer)
        uploadPhotoContainer.addSubview(uploadPhotoImageView)
        uploadPhotoContainer.addSubview(uploadPhotoButton)
        contentView.addSubview(formStackView)
        contentView.addSubview(doneButton)
        contentView.addSubview(cancelButton)
    }

    private func applyMetrics() {
        let titleFont = UIFont(name: "Raleway-Bold", size: metrics.titleFontSize) ?? .systemFont(ofSize: metrics.titleFontSize, weight: .bold)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = metrics.titleLineHeight
        paragraphStyle.maximumLineHeight = metrics.titleLineHeight
        titleLabel.attributedText = NSAttributedString(
            string: "Create \nAccount",
            attributes: [
                .font: titleFont,
                .foregroundColor: UIColor(hex: "#202020"),
                .kern: -0.5,
                .paragraphStyle: paragraphStyle
            ]
        )

        doneButton.titleLabel?.font = UIFont(name: "NunitoSans-Bold", size: metrics.doneButtonFontSize) ?? .systemFont(ofSize: metrics.doneButtonFontSize, weight: .bold)
        cancelButton.titleLabel?.font = UIFont(name: "NunitoSans-Light", size: metrics.cancelFontSize) ?? .systemFont(ofSize: metrics.cancelFontSize, weight: .light)
        updateDoneButtonState(isEnabled: false)

        emailField.returnKeyType = .next
        passwordField.returnKeyType = .next
        phoneField.returnKeyType = .done
    }

    private func setupConstraints() {
        backgroundLightImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.size.equalTo(metrics.backgroundLightSize)
        }

        backgroundBlueImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(metrics.backgroundBlueTop)
            make.trailing.equalToSuperview()
            make.size.equalTo(metrics.backgroundBlueSize)
        }

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.safeAreaLayoutGuide.snp.edges)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide.snp.edges)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
            make.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide.snp.height)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(metrics.titleTopInset)
            make.leading.equalToSuperview().offset(metrics.titleLeadingInset)
            make.width.equalTo(metrics.titleWidth)
        }

        uploadPhotoContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(metrics.titleToUploadSpacing)
            make.leading.equalToSuperview().offset(metrics.uploadLeadingInset)
            make.size.equalTo(CGSize(width: metrics.uploadSize, height: metrics.uploadSize))
        }

        uploadPhotoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        uploadPhotoButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        formStackView.snp.makeConstraints { make in
            make.top.equalTo(uploadPhotoContainer.snp.bottom).offset(metrics.uploadToFormSpacing)
            make.leading.equalToSuperview().offset(metrics.horizontalInset)
            make.trailing.equalToSuperview().inset(metrics.horizontalInset)
        }

        emailField.snp.makeConstraints { make in
            make.height.equalTo(metrics.textFieldHeight)
        }

        passwordField.snp.makeConstraints { make in
            make.height.equalTo(metrics.textFieldHeight)
        }

        phoneField.snp.makeConstraints { make in
            make.height.equalTo(metrics.phoneFieldHeight)
        }

        doneButton.snp.makeConstraints { make in
            make.top.equalTo(formStackView.snp.bottom).offset(metrics.formToButtonSpacing)
            make.leading.equalToSuperview().offset(metrics.horizontalInset)
            make.trailing.equalToSuperview().inset(metrics.horizontalInset)
            make.height.equalTo(metrics.doneButtonHeight)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(doneButton.snp.bottom).offset(metrics.buttonToCancelSpacing)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(metrics.bottomInset)
        }
    }

    private func setupActions() {
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        uploadPhotoButton.addTarget(self, action: #selector(uploadPhotoTapped), for: .touchUpInside)

        emailField.onTextChanged = { [weak self] text in
            self?.onEmailChanged?(text)
        }

        passwordField.onTextChanged = { [weak self] text in
            self?.onPasswordChanged?(text)
        }

        phoneField.onTextChanged = { [weak self] text in
            self?.onPhoneChanged?(text)
        }

        emailField.onEditingDidBegin = { [weak self] in
            self?.activeInputContainerView = self?.emailField
        }

        passwordField.onEditingDidBegin = { [weak self] in
            self?.activeInputContainerView = self?.passwordField
        }

        phoneField.onEditingDidBegin = { [weak self] in
            self?.activeInputContainerView = self?.phoneField
        }

        emailField.onReturnKeyTapped = { [weak self] in
            self?.passwordField.becomeInputFirstResponder()
        }

        passwordField.onReturnKeyTapped = { [weak self] in
            self?.phoneField.becomeInputFirstResponder()
        }

        phoneField.onReturnKeyTapped = { [weak self] in
            self?.phoneField.resignInputFirstResponder()
        }
    }

    @objc private func doneButtonTapped() {
        onDoneButtonTapped?()
    }

    @objc private func cancelButtonTapped() {
        onCancelButtonTapped?()
    }

    @objc private func uploadPhotoTapped() {
        onUploadPhotoTapped?()
    }

    func updateAvatarImage(_ image: UIImage?) {
        if let image {
            uploadPhotoImageView.image = image
            uploadPhotoImageView.contentMode = .scaleAspectFill
            uploadPhotoImageView.layer.cornerRadius = metrics.uploadSize / 2
            uploadPhotoImageView.layer.masksToBounds = true
            return
        }

        uploadPhotoImageView.image = UIImage(named: "upload_photo")
        uploadPhotoImageView.contentMode = .scaleAspectFit
        uploadPhotoImageView.layer.cornerRadius = 0
        uploadPhotoImageView.layer.masksToBounds = false
    }

    func updateDoneButtonState(isEnabled: Bool) {
        doneButton.isEnabled = isEnabled
        doneButton.alpha = isEnabled ? 1 : 0.55
    }

    func updateForKeyboard(
        keyboardFrameInView: CGRect,
        animationDuration: TimeInterval,
        animationOptions: UIView.AnimationOptions
    ) {
        let keyboardFrameInSelf = convert(keyboardFrameInView, from: nil)
        let overlapHeight = max(0, bounds.maxY - keyboardFrameInSelf.minY)
        let bottomInset = overlapHeight > 0 ? max(0, overlapHeight - safeAreaInsets.bottom) + 20 : 0

        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            options: [animationOptions, .beginFromCurrentState],
            animations: {
                self.scrollView.contentInset.bottom = bottomInset
                self.scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
                self.scrollToActiveInputIfNeeded()
            }
        )
    }

    private func scrollToActiveInputIfNeeded() {
        guard let activeInputContainerView else { return }

        let targetRect = activeInputContainerView.convert(activeInputContainerView.bounds, to: scrollView)
        scrollView.scrollRectToVisible(targetRect.insetBy(dx: 0, dy: -24), animated: false)
    }
}

private struct CreateAccountMetrics {
    let backgroundLightSize: CGSize
    let backgroundBlueSize: CGSize
    let backgroundBlueTop: CGFloat
    let titleTopInset: CGFloat
    let titleLeadingInset: CGFloat
    let titleWidth: CGFloat
    let titleFontSize: CGFloat
    let titleLineHeight: CGFloat
    let titleToUploadSpacing: CGFloat
    let uploadLeadingInset: CGFloat
    let uploadSize: CGFloat
    let horizontalInset: CGFloat
    let uploadToFormSpacing: CGFloat
    let formSpacing: CGFloat
    let textFieldHeight: CGFloat
    let phoneFieldHeight: CGFloat
    let formToButtonSpacing: CGFloat
    let doneButtonHeight: CGFloat
    let doneButtonFontSize: CGFloat
    let buttonToCancelSpacing: CGFloat
    let cancelFontSize: CGFloat
    let bottomInset: CGFloat

    static func current(screenHeight: CGFloat) -> CreateAccountMetrics {
        CreateAccountMetrics(
            backgroundLightSize: CGSize(
                width: AdaptiveLayout.value(compact: 200, regular: 228, expanded: 246, for: screenHeight),
                height: AdaptiveLayout.value(compact: 186, regular: 212.5, expanded: 229, for: screenHeight)
            ),
            backgroundBlueSize: CGSize(
                width: AdaptiveLayout.value(compact: 82, regular: 91.5, expanded: 102, for: screenHeight),
                height: AdaptiveLayout.value(compact: 240, regular: 267, expanded: 298, for: screenHeight)
            ),
            backgroundBlueTop: AdaptiveLayout.value(compact: 28, regular: 41, expanded: 54, for: screenHeight),
            titleTopInset: AdaptiveLayout.value(compact: 54, regular: 78, expanded: 94, for: screenHeight),
            titleLeadingInset: AdaptiveLayout.value(compact: 24, regular: 30, expanded: 32, for: screenHeight),
            titleWidth: AdaptiveLayout.value(compact: 184, regular: 197, expanded: 208, for: screenHeight),
            titleFontSize: AdaptiveLayout.value(compact: 44, regular: 50, expanded: 54, for: screenHeight),
            titleLineHeight: AdaptiveLayout.value(compact: 48, regular: 54, expanded: 58, for: screenHeight),
            titleToUploadSpacing: AdaptiveLayout.value(compact: 40, regular: 56, expanded: 66, for: screenHeight),
            uploadLeadingInset: AdaptiveLayout.value(compact: 24, regular: 30, expanded: 32, for: screenHeight),
            uploadSize: AdaptiveLayout.value(compact: 82, regular: 90, expanded: 96, for: screenHeight),
            horizontalInset: AdaptiveLayout.value(compact: 20, regular: 20, expanded: 24, for: screenHeight),
            uploadToFormSpacing: AdaptiveLayout.value(compact: 26, regular: 32, expanded: 40, for: screenHeight),
            formSpacing: AdaptiveLayout.value(compact: 8, regular: 8, expanded: 10, for: screenHeight),
            textFieldHeight: AdaptiveLayout.value(compact: 50, regular: 52.37, expanded: 54, for: screenHeight),
            phoneFieldHeight: AdaptiveLayout.value(compact: 53, regular: 55.34, expanded: 57, for: screenHeight),
            formToButtonSpacing: AdaptiveLayout.value(compact: 24, regular: 32, expanded: 40, for: screenHeight),
            doneButtonHeight: AdaptiveLayout.value(compact: 58, regular: 61, expanded: 64, for: screenHeight),
            doneButtonFontSize: AdaptiveLayout.value(compact: 20, regular: 22, expanded: 23, for: screenHeight),
            buttonToCancelSpacing: AdaptiveLayout.value(compact: 18, regular: 24, expanded: 28, for: screenHeight),
            cancelFontSize: AdaptiveLayout.value(compact: 14, regular: 15, expanded: 16, for: screenHeight),
            bottomInset: AdaptiveLayout.value(compact: 18, regular: 24, expanded: 32, for: screenHeight)
        )
    }

    @MainActor
    static func current() -> CreateAccountMetrics {
        current(screenHeight: UIScreen.main.bounds.height)
    }
}

private final class CreateAccountInputField: UIView {
    private let textField = UITextField()
    private let trailingImageView: UIImageView?
    var onTextChanged: ((String) -> Void)?
    var onReturnKeyTapped: (() -> Void)?
    var onEditingDidBegin: (() -> Void)?

    var returnKeyType: UIReturnKeyType = .default {
        didSet {
            textField.returnKeyType = returnKeyType
        }
    }

    init(placeholder: String, trailingSystemImageName: String? = nil) {
        if let trailingSystemImageName {
            let imageView = UIImageView(image: UIImage(systemName: trailingSystemImageName))
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = UIColor(hex: "#D2D2D2")
            trailingImageView = imageView
        } else {
            trailingImageView = nil
        }

        super.init(frame: .zero)
        textField.placeholder = placeholder
        if placeholder == "Email" {
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
            textField.textContentType = .emailAddress
        } else if placeholder == "Password" {
            textField.isSecureTextEntry = true
            textField.textContentType = .newPassword
        }
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor(hex: "#F8F8F8")
        layer.cornerRadius = 26.18

        textField.borderStyle = .none
        textField.textColor = UIColor(hex: "#202020")
        textField.font = UIFont(name: "Poppins-Medium", size: 14) ?? .systemFont(ofSize: 14, weight: .medium)
        textField.attributedPlaceholder = NSAttributedString(
            string: textField.placeholder ?? "",
            attributes: [.foregroundColor: UIColor(hex: "#D2D2D2")]
        )
        textField.autocorrectionType = .no
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        addSubview(textField)

        if let trailingImageView {
            addSubview(trailingImageView)
        }
    }

    private func setupConstraints() {
        if let trailingImageView {
            trailingImageView.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(19.76)
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 15.81, height: 15.81))
            }

            textField.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(19.76)
                make.trailing.equalTo(trailingImageView.snp.leading).offset(-12)
                make.centerY.equalToSuperview()
            }
        } else {
            textField.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(19.76)
                make.centerY.equalToSuperview()
            }
        }
    }

    @objc private func textDidChange() {
        onTextChanged?(textField.text ?? "")
    }

    func becomeInputFirstResponder() {
        textField.becomeFirstResponder()
    }
}

extension CreateAccountInputField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        onEditingDidBegin?()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturnKeyTapped?()
        return false
    }
}

private final class CreateAccountPhoneField: UIView {
    private let countryButton = UIButton(type: .custom)

    private let flagLabel: UILabel = {
        let label = UILabel()
        label.text = "🇬🇧"
        label.font = .systemFont(ofSize: 20)
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(hex: "#202020")
        return imageView
    }()

    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#DADADA")
        return view
    }()

    private let textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.textColor = UIColor(hex: "#202020")
        textField.font = UIFont(name: "Poppins-Medium", size: 14) ?? .systemFont(ofSize: 14, weight: .medium)
        textField.keyboardType = .numbersAndPunctuation
        textField.autocorrectionType = .no
        textField.textContentType = .telephoneNumber
        return textField
    }()
    var onTextChanged: ((String) -> Void)?
    var onReturnKeyTapped: (() -> Void)?
    var onEditingDidBegin: (() -> Void)?

    var returnKeyType: UIReturnKeyType = .default {
        didSet {
            textField.returnKeyType = returnKeyType
        }
    }

    init(placeholder: String) {
        super.init(frame: .zero)
        textField.placeholder = placeholder
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(hex: "#D2D2D2")]
        )
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor(hex: "#F8F8F8")
        layer.cornerRadius = 27.67

        textField.delegate = self
        addSubview(countryButton)
        addSubview(flagLabel)
        addSubview(chevronImageView)
        addSubview(dividerView)
        addSubview(textField)
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

    private func setupConstraints() {
        countryButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(79.06)
        }

        flagLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(19.76)
            make.centerY.equalToSuperview()
        }

        chevronImageView.snp.makeConstraints { make in
            make.leading.equalTo(flagLabel.snp.trailing).offset(7.91)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 15.81, height: 15.81))
        }

        dividerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(79.06)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(23.72)
        }

        textField.snp.makeConstraints { make in
            make.leading.equalTo(dividerView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(31.62)
            make.centerY.equalToSuperview()
        }
    }

    @objc private func textDidChange() {
        onTextChanged?(textField.text ?? "")
    }

    func becomeInputFirstResponder() {
        textField.becomeFirstResponder()
    }

    func resignInputFirstResponder() {
        textField.resignFirstResponder()
    }
}

extension CreateAccountPhoneField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        onEditingDidBegin?()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturnKeyTapped?()
        return false
    }
}
