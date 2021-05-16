import UIKit
import TLPhotoPicker

class ViewerAssets {
    static let bundle = Bundle(for: ViewerAssets.self)
}

extension UIImage {
    static var darkCircle = TLBundle.podBundleImage(named: "dark-circle")!
    static var pause = TLBundle.podBundleImage(named: "pause")!
    static var play = TLBundle.podBundleImage(named: "play")!
    static var `repeat` = TLBundle.podBundleImage(named: "repeat")!
    static var seek = TLBundle.podBundleImage(named: "seek")!
    public static var close = TLBundle.podBundleImage(named: "close")!

    convenience init(name: String) {
        self.init(named: name, in: ViewerAssets.bundle, compatibleWith: nil)!
    }
}
