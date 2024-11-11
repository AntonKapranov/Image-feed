import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var isProgressHUDActive = false
    
    static func show() {
        if let window = UIApplication.shared.windows.first {
            window.isUserInteractionEnabled = false
        }
        ProgressHUD.animate()
        isProgressHUDActive = true
    }
    
    static func dismiss() {
        if let window = UIApplication.shared.windows.first {
            window.isUserInteractionEnabled = true
        }
        ProgressHUD.dismiss()
        isProgressHUDActive = false
    }
    
    static var isActive: Bool {
        return isProgressHUDActive
    }
}


