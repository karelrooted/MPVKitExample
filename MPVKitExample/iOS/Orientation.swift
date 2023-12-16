#if os(iOS)
import CoreMotion
import Defaults
import Logging
import UIKit

struct Orientation {
    static var logger = Logger(label: "stream.yattee.orientation")

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        return
    }

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation: UIInterfaceOrientation? = nil) {
        lockOrientation(orientation)

        guard let rotateOrientation else {
            return
        }

        let orientationString = rotateOrientation == .portrait ? "portrait" : rotateOrientation == .landscapeLeft ? "landscapeLeft" :
            rotateOrientation == .landscapeRight ? "landscapeRight" : rotateOrientation == .portraitUpsideDown ? "portraitUpsideDown" : "allButUpsideDown"

        logger.info("rotating to \(orientationString)")

        if #available(iOS 16, *) {
            guard let windowScene = Self.scene else { return }
            let rotateOrientationMask = rotateOrientation == .portrait ? UIInterfaceOrientationMask.portrait :
                rotateOrientation == .landscapeLeft ? .landscapeLeft :
                rotateOrientation == .landscapeRight ? .landscapeRight :
                .allButUpsideDown

            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: rotateOrientationMask)) { error in
                print("denied rotation \(error)")
            }
        } else {
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }

        UINavigationController.attemptRotationToDeviceOrientation()
    }

    private static var scene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first
    }
}
#endif
