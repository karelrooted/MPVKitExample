#if os(iOS) || os(tvOS)
import UIKit

extension UIViewController {
    @objc var swizzle_prefersHomeIndicatorAutoHidden: Bool {
        true
    }

    public class func swizzleHomeIndicatorProperty() {
        return
    }
}
#endif
