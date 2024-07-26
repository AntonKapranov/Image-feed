import UIKit

extension UIColor {
    static var ypBackground: UIColor {UIColor(named: "YP Background") ?? UIColor.systemBackground}
    static var ypBlack: UIColor {UIColor(named: "YP Black") ?? UIColor.black}
    static var ypBlue:UIColor {UIColor(named: "YP Blue") ?? UIColor.blue}
    static var ypRed:UIColor {UIColor(named: "YP Red") ?? UIColor.red}
    static var ypGray:UIColor {UIColor(named: "YP Gray") ?? UIColor.gray}
    static var ypWhite_1:UIColor {UIColor(named: "YP White") ?? UIColor.white}
    static var ypWhite_05:UIColor {UIColor(named: "YP White (Alpha 50") ?? UIColor.white}
}

//@IBDesignable
//class GradientView: UIView {
//
//    @IBInspectable var startColor: UIColor = .white {
//        didSet {
//            updateGradientColors()
//        }
//    }
//    
//    @IBInspectable var endColor: UIColor = .black {
//        didSet {
//            updateGradientColors()
//        }
//    }
//    
//    @IBInspectable var startPoint: CGPoint = CGPoint(x: 0, y: 0) {
//        didSet {
//            updateGradientPoints()
//        }
//    }
//    
//    @IBInspectable var endPoint: CGPoint = CGPoint(x: 1, y: 1) {
//        didSet {
//            updateGradientPoints()
//        }
//    }
//    
//    @IBInspectable var topLeftRadius: CGFloat = 0 {
//        didSet {
//            updateCornerRadii()
//        }
//    }
//    
//    @IBInspectable var topRightRadius: CGFloat = 0 {
//        didSet {
//            updateCornerRadii()
//        }
//    }
//    
//    @IBInspectable var bottomLeftRadius: CGFloat = 0 {
//        didSet {
//            updateCornerRadii()
//        }
//    }
//    
//    @IBInspectable var bottomRightRadius: CGFloat = 0 {
//        didSet {
//            updateCornerRadii()
//        }
//    }
//
//    private var gradientLayer: CAGradientLayer {
//        return layer as! CAGradientLayer
//    }
//
//    override class var layerClass: AnyClass {
//        return CAGradientLayer.self
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setup()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setup()
//    }
//
//    private func setup() {
//        updateGradientColors()
//        updateGradientPoints()
//        updateCornerRadii()
//    }
//    
//    private func updateGradientColors() {
//        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
//    }
//    
//    private func updateGradientPoints() {
//        gradientLayer.startPoint = startPoint
//        gradientLayer.endPoint = endPoint
//    }
//    
//    private func updateCornerRadii() {
//        let path = UIBezierPath()
//
//        // Top left corner
//        path.move(to: CGPoint(x: 0, y: topLeftRadius))
//        path.addQuadCurve(to: CGPoint(x: topLeftRadius, y: 0), controlPoint: CGPoint.zero)
//        
//        // Top right corner
//        path.addLine(to: CGPoint(x: bounds.width - topRightRadius, y: 0))
//        path.addQuadCurve(to: CGPoint(x: bounds.width, y: topRightRadius), controlPoint: CGPoint(x: bounds.width, y: 0))
//        
//        // Bottom right corner
//        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height - bottomRightRadius))
//        path.addQuadCurve(to: CGPoint(x: bounds.width - bottomRightRadius, y: bounds.height), controlPoint: CGPoint(x: bounds.width, y: bounds.height))
//        
//        // Bottom left corner
//        path.addLine(to: CGPoint(x: bottomLeftRadius, y: bounds.height))
//        path.addQuadCurve(to: CGPoint(x: 0, y: bounds.height - bottomLeftRadius), controlPoint: CGPoint(x: 0, y: bounds.height))
//        
//        path.close()
//        
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        gradientLayer.mask = mask
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        updateCornerRadii()
//    }

