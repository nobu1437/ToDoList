import Foundation

extension UserDefaults {
    var isFirstLaunch: Bool {
        get {
            !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        }
        set {
            UserDefaults.standard.set(!newValue, forKey: "hasLaunchedBefore")
        }
    }
}
