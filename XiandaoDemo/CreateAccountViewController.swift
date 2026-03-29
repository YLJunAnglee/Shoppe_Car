import UIKit

final class CreateAccountViewController: UIViewController {
    private let createAccountView = CreateAccountView()

    override func loadView() {
        view = createAccountView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
        createAccountView.onDoneButtonTapped = {
            // TODO: 后续接入创建账户逻辑
        }

        createAccountView.onCancelButtonTapped = {
            // TODO: 后续接入取消返回逻辑
        }

        createAccountView.onUploadPhotoTapped = {
            // TODO: 后续接入上传头像逻辑
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
}
