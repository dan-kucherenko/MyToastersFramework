import UIKit

extension UIApplication {
    open override var next: UIResponder? {
        UIApplication.runOnce
        return super.next
    }

    private static let runOnce: Void = {
        _ = KeyboardObserver.shared
    }()
}
