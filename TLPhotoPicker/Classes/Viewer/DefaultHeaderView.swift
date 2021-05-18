import UIKit

protocol DefaultHeaderViewDelegate: class {
    func headerView(_ headerView: DefaultHeaderView, didPressClearButton button: UIButton)
    func toggleSelectBtn(isSelected: Bool)
}

class DefaultHeaderView: UIView {
    weak var delegate: DefaultHeaderViewDelegate?
    static let ButtonSize = CGFloat(50.0)
    static let labelSize = CGFloat(24.0)
    static let TopMargin = CGFloat(14.0)
    static var selectedColor = UIColor(red: 79/255, green: 0/255, blue: 247/255, alpha: 1.0)

    public var isSelected: Bool = false {
        willSet(value) {
            orderLabel.layer.borderColor = value ? DefaultHeaderView.selectedColor.cgColor : UIColor.white.cgColor
            orderLabel.backgroundColor = value ? DefaultHeaderView.selectedColor : UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        }
    }
    
    lazy var clearButton: UIButton = {
        let image = UIImage.close
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.contentMode = .center
        button.imageView?.contentMode = .scaleAspectFit
        let diff = (DefaultHeaderView.ButtonSize - DefaultHeaderView.labelSize)/2
        button.contentEdgeInsets = UIEdgeInsets(top: diff, left: diff, bottom: diff, right: diff)
        button.addTarget(self, action: #selector(DefaultHeaderView.clearAction(button:)), for: .touchUpInside)
        button.layer.masksToBounds = true
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 4.0
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 1, height: 2)
        return button
    }()
    
    lazy open var orderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .center
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.clipsToBounds = true
        label.layer.cornerRadius = 12
        label.layer.borderWidth = 2.5
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.masksToBounds = true
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 4.0
        label.layer.shadowOpacity = 0.25
        label.layer.shadowOffset = CGSize(width: 1, height: 2)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(self.clearButton)
        self.addSubview(self.orderLabel)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let diff = (DefaultHeaderView.ButtonSize - DefaultHeaderView.labelSize)/2
        clearButton.frame = CGRect(x: 4, y: DefaultHeaderView.TopMargin, width: DefaultHeaderView.ButtonSize, height: DefaultHeaderView.ButtonSize)
        
        orderLabel.frame = CGRect(x: self.frame.size.width - DefaultHeaderView.labelSize - 4 - diff, y: DefaultHeaderView.TopMargin + diff, width: DefaultHeaderView.labelSize, height: DefaultHeaderView.labelSize)
    }

    @objc func clearAction(button: UIButton) {
        self.delegate?.headerView(self, didPressClearButton: button)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        let touch = touches.first
        let point = touch?.location(in: self)
        if let _point = point, checkLabelTouch(point: _point) {
            delegate?.toggleSelectBtn(isSelected: orderLabel.layer.borderColor != DefaultHeaderView.selectedColor.cgColor)
        }
    }
    
    private func checkLabelTouch(point: CGPoint) -> Bool {
        let diff = (DefaultHeaderView.ButtonSize - DefaultHeaderView.labelSize)/2
        var insets = UIEdgeInsets(top: diff, left: diff, bottom: diff, right: diff)
        var rect = orderLabel.frame
        rect.origin.x -= insets.left
        rect.origin.y -= insets.top
        rect.size.width += insets.left + insets.right
        rect.size.height += insets.top + insets.bottom
        return rect.contains(point)
    }
}
