import UIKit

extension UIView {
    func addGradiend (colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.cornerRadius = layer.cornerRadius
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

//extension CAGradientLayer {
//    func configureGradient(colors: [UIColor], locations: [NSNumber]? = nil, startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)) {
//        self.colors = colors.map { $0.cgColor }
//        self.locations = locations
//        self.startPoint = startPoint
//        self.endPoint = endPoint
//    }
//}


//extension CAGradientLayer { //for gradientCell
//    static func gradientLayer(in frame: CGRect) -> Self {
//        let layer = Self()
//        layer.colors = colors()
//        layer.frame = frame
//        return layer
//    }
//
//    private static func colors() -> [CGColor] {
//        let beginColor: CGColor = UIColor(named:"YP Black")!.cgColor
//        let endColor: CGColor = UIColor(named:"YP Black (Alpha 0)")!.cgColor
//
//        return [beginColor, endColor]
//    }
//}

//extension CAGradientLayer {
//    private static func Colors ()
//}
