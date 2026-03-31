import UIKit

@MainActor
final class AvatarSelectionService {
    private let avatarPickerTool = AvatarPickerTool()

    private(set) var selectedAvatarImage: UIImage? {
        didSet {
            onAvatarImageChanged?(selectedAvatarImage)
        }
    }

    var onAvatarImageChanged: ((UIImage?) -> Void)?
    var onAvatarSelectionError: ((String) -> Void)?

    func selectAvatar(from presentingViewController: UIViewController) {
        avatarPickerTool.present(from: presentingViewController) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let image):
                selectedAvatarImage = image
            case .cancelled:
                break
            case .failure(let error):
                onAvatarSelectionError?(error.localizedDescription)
            }
        }
    }

    func clearAvatar() {
        selectedAvatarImage = nil
    }
}
