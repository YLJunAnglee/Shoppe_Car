import UIKit

final class CreateAccountViewController: UIViewController {
    private let createAccountView = CreateAccountView()
    private let viewModel = CreateAccountViewModel()

    override func loadView() {
        view = createAccountView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardObservers()
        bindAvatarSelection()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupBindings() {
        createAccountView.onDoneButtonTapped = { [weak self] in
            self?.viewModel.handleDoneButtonTap()
        }

        createAccountView.onCancelButtonTapped = { [weak self] in
            self?.viewModel.handleCancelButtonTap()
        }

        createAccountView.onUploadPhotoTapped = { [weak self] in
            guard let self else { return }
            self.viewModel.handleUploadPhotoTap(from: self)
        }

        createAccountView.onEmailChanged = { [weak self] text in
            self?.viewModel.handleEmailChanged(text)
        }

        createAccountView.onPasswordChanged = { [weak self] text in
            self?.viewModel.handlePasswordChanged(text)
        }

        createAccountView.onPhoneChanged = { [weak self] text in
            self?.viewModel.handlePhoneChanged(text)
        }
    }

    private func bindAvatarSelection() {
        viewModel.onAvatarImageChanged = { [weak self] image in
            self?.createAccountView.updateAvatarImage(image)
        }

        viewModel.onDoneButtonStateChanged = { [weak self] isEnabled in
            self?.createAccountView.updateDoneButtonState(isEnabled: isEnabled)
        }

        viewModel.onErrorMessage = { [weak self] message in
            self?.presentErrorAlert(message: message)
        }

        viewModel.onCancelRequested = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        viewModel.onCreateAccountRequested = { [weak self] formData in
            self?.presentCreateAccountPendingAlert(for: formData)
        }
    }

    private func presentErrorAlert(message: String) {
        let alertController = UIAlertController(
            title: "Check your information",
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }

    private func presentCreateAccountPendingAlert(for formData: CreateAccountFormData) {
        let alertController = UIAlertController(
            title: "Account creation pending",
            message: "Email: \(formData.email)\nPhone: \(formData.phoneNumber)\nAvatar selected: \(formData.avatarImage == nil ? "No" : "Yes")",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension CreateAccountViewController {
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardNotification(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc func handleKeyboardNotification(_ notification: Notification) {
        guard let transition = KeyboardTransition(notification: notification) else {
            return
        }

        createAccountView.updateForKeyboard(
            keyboardFrameInView: transition.frameEnd,
            animationDuration: transition.animationDuration,
            animationOptions: transition.animationOptions
        )
    }
}
