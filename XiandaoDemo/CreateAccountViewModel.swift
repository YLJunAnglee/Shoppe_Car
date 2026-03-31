import UIKit

struct CreateAccountFormData {
    let email: String
    let password: String
    let phoneNumber: String
    let avatarImage: UIImage?
}

@MainActor
final class CreateAccountViewModel {
    private let avatarSelectionService = AvatarSelectionService()

    private var email = ""
    private var password = ""
    private var phoneNumber = ""
    private var isFormSubmittable = false

    var onAvatarImageChanged: ((UIImage?) -> Void)?
    var onDoneButtonStateChanged: ((Bool) -> Void)?
    var onErrorMessage: ((String) -> Void)?
    var onCancelRequested: (() -> Void)?
    var onCreateAccountRequested: ((CreateAccountFormData) -> Void)?

    init() {
        bindAvatarSelection()
    }

    var selectedAvatarImage: UIImage? {
        avatarSelectionService.selectedAvatarImage
    }

    func handleEmailChanged(_ value: String) {
        email = value.trimmingCharacters(in: .whitespacesAndNewlines)
        validateForm()
    }

    func handlePasswordChanged(_ value: String) {
        password = value
        validateForm()
    }

    func handlePhoneChanged(_ value: String) {
        phoneNumber = value.trimmingCharacters(in: .whitespacesAndNewlines)
        validateForm()
    }

    func handleUploadPhotoTap(from presentingViewController: UIViewController) {
        avatarSelectionService.selectAvatar(from: presentingViewController)
    }

    func handleDoneButtonTap() {
        guard isFormSubmittable else {
            onErrorMessage?("Please enter a valid email, password, and phone number.")
            return
        }

        onCreateAccountRequested?(
            CreateAccountFormData(
                email: email,
                password: password,
                phoneNumber: phoneNumber,
                avatarImage: selectedAvatarImage
            )
        )
    }

    func handleCancelButtonTap() {
        onCancelRequested?()
    }

    private func bindAvatarSelection() {
        avatarSelectionService.onAvatarImageChanged = { [weak self] image in
            self?.onAvatarImageChanged?(image)
        }

        avatarSelectionService.onAvatarSelectionError = { [weak self] message in
            self?.onErrorMessage?(message)
        }
    }

    private func validateForm() {
        let isValid = isValidEmail(email) && isValidPassword(password) && isValidPhoneNumber(phoneNumber)
        guard isValid != isFormSubmittable else { return }

        isFormSubmittable = isValid
        onDoneButtonStateChanged?(isValid)
    }

    private func isValidEmail(_ value: String) -> Bool {
        let emailPattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return value.range(of: emailPattern, options: .regularExpression) != nil
    }

    private func isValidPassword(_ value: String) -> Bool {
        value.count >= 6
    }

    private func isValidPhoneNumber(_ value: String) -> Bool {
        let digits = value.filter(\.isNumber)
        return digits.count >= 6
    }
}
