import UIKit

extension UIImage {

    func centeredFrame() -> CGRect {
        let screenBounds = UIScreen.main.bounds
        let widthScaleFactor = self.size.width / screenBounds.size.width
        let heightScaleFactor = self.size.height / screenBounds.size.height
        var centeredFrame = CGRect.zero
        
        let shouldFitHorizontally = widthScaleFactor > heightScaleFactor
        if size.width > size.height {
            let height = ceil(self.size.height / widthScaleFactor) + 1
            let y = (screenBounds.size.height / 2) - (height / 2)
            centeredFrame = CGRect(x: 0, y: y, width: screenBounds.size.width, height: height)
        } else {
            var x = (screenBounds.size.width / 2) - ((self.size.width / heightScaleFactor) / 2)
            x = x < 5 ? 0 : x
            centeredFrame = CGRect(x: x, y: 0, width: screenBounds.size.width - (2 * x), height: screenBounds.size.height)
        }
        return centeredFrame
    }
}
