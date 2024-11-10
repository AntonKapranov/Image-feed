import UIKit

class OAuth2TokenStorage {
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "OAuth2AccessToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "OAuth2AccessToken")
        }
    }
}
