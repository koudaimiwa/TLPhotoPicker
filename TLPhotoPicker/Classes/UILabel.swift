//
//  UILabel.swift
//  Pods-TLPhotoPicker_Example
//
//  Created by 三輪航大 on 2021/05/20.
//

import Foundation

extension UILabel {
    func insertImage(_ image: UIImage, at index: Int, size: CGSize? = nil, alignment: NSTextAttachment.VerticalAlignment = .center) {
        let attr = attributedText as? NSMutableAttributedString ?? NSMutableAttributedString(string: text ?? "")
        let attachment = NSTextAttachment(image: image, font: font, size: size ?? image.size, alignment: alignment)
        attr.insert(NSAttributedString(attachment: attachment), at: index)
        attributedText = attr
    }
}

extension NSTextAttachment {
    convenience init(image: UIImage, font: UIFont, size: CGSize, alignment: VerticalAlignment) {
        self.init()
        self.image = image
        let y: CGFloat
        switch alignment {
        case .top:
            y = font.capHeight - size.height
        case .bottom:
            y = font.descender
        case .center:
            y = (font.capHeight - size.height).rounded() / 2
        case .baseline:
            y = 0
        }
        bounds.origin = CGPoint(x: 0, y: y)
        bounds.size = size
    }

    enum VerticalAlignment {
        case bottom, baseline, center, top
    }
}
