import UIKit

struct KeyboardTransition {
    let frameEnd: CGRect
    let animationDuration: TimeInterval
    let animationOptions: UIView.AnimationOptions

    init?(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let frameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return nil
        }

        let animationDuration =
            (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let animationCurveRawValue =
            (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue
            ?? UInt(UIView.AnimationCurve.easeInOut.rawValue)

        self.frameEnd = frameEnd
        self.animationDuration = animationDuration
        self.animationOptions = UIView.AnimationOptions(rawValue: animationCurveRawValue << 16)
    }
}
