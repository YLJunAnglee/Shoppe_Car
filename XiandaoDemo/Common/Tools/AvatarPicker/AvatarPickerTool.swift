import UIKit
import PhotosUI
import UniformTypeIdentifiers
import Mantis

enum AvatarPickerResult {
    case success(UIImage)
    case cancelled
    case failure(AvatarPickerToolError)
}

enum AvatarPickerToolError: LocalizedError {
    case presentationContextUnavailable
    case unsupportedImageType
    case failedToLoadImage
    case cropFailed

    var errorDescription: String? {
        switch self {
        case .presentationContextUnavailable:
            return "Unable to present the avatar picker right now."
        case .unsupportedImageType:
            return "The selected item is not a supported image."
        case .failedToLoadImage:
            return "Unable to load the selected photo."
        case .cropFailed:
            return "Unable to crop the selected photo."
        }
    }
}

@MainActor
final class AvatarPickerTool: NSObject {
    private weak var presentingViewController: UIViewController?
    private var completion: ((AvatarPickerResult) -> Void)?

    func present(
        from presentingViewController: UIViewController,
        completion: @escaping (AvatarPickerResult) -> Void
    ) {
        self.presentingViewController = presentingViewController
        self.completion = completion
        presentPhotoPicker()
    }

    func reset() {
        presentingViewController = nil
        completion = nil
    }

    private func presentPhotoPicker() {
        guard let presentingViewController else {
            complete(with: .failure(.presentationContextUnavailable))
            return
        }

        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1
        configuration.preferredAssetRepresentationMode = .current

        let pickerViewController = PHPickerViewController(configuration: configuration)
        pickerViewController.delegate = self
        presentingViewController.present(pickerViewController, animated: true)
    }

    private func presentCropper(with image: UIImage) {
        guard let presentingViewController else {
            complete(with: .failure(.presentationContextUnavailable))
            return
        }

        var config = Mantis.Config()
        config.cropViewConfig.cropShapeType = .circle(maskOnly: false)
        config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 1)
        config.appearanceMode = .forceLight

        let cropViewController = Mantis.cropViewController(image: image, config: config)
        cropViewController.delegate = self
        cropViewController.modalPresentationStyle = .fullScreen
        presentingViewController.present(cropViewController, animated: true)
    }

    private func complete(with result: AvatarPickerResult) {
        let completion = self.completion
        reset()
        completion?(result)
    }
}

extension AvatarPickerTool: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            guard let itemProvider = results.first?.itemProvider else {
                self.complete(with: .cancelled)
                return
            }

            guard itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) else {
                self.complete(with: .failure(.unsupportedImageType))
                return
            }

            itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] data, error in
                Task { @MainActor in
                    guard let self else { return }

                    guard
                        error == nil,
                        let data,
                        let image = UIImage(data: data)
                    else {
                        self.complete(with: .failure(.failedToLoadImage))
                        return
                    }

                    self.presentCropper(with: image)
                }
            }
        }
    }
}

extension AvatarPickerTool: @preconcurrency CropViewControllerDelegate {
    func cropViewControllerDidCrop(
        _ cropViewController: CropViewController,
        cropped: UIImage,
        transformation: Transformation,
        cropInfo: CropInfo
    ) {
        cropViewController.dismiss(animated: true) { [weak self] in
            self?.complete(with: .success(cropped))
        }
    }

    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: true) { [weak self] in
            self?.complete(with: .cancelled)
        }
    }

    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: true) { [weak self] in
            self?.complete(with: .failure(.cropFailed))
        }
    }
}
