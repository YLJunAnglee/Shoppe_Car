import Foundation

@MainActor
final class SessionManager {
    static let shared = SessionManager()

    private let userDefaults: UserDefaults
    private let isLoggedInKey = "isLoggedIn"

    var isLoggedIn: Bool {
        get {
            userDefaults.bool(forKey: isLoggedInKey)
        }
        set {
            userDefaults.set(newValue, forKey: isLoggedInKey)
        }
    }

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
}
