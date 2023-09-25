import UIKit

final class Colors {
    var viewBackgroundColor = UIColor.systemBackground
    var datePickerTintColor = UIColor { (traits) -> UIColor in
        let isDarkMode = traits.userInterfaceStyle == .dark
        return isDarkMode ? UIColor.black : UIColor.black
    }
}

extension UIColor {
    static let backgroundColor = UIColor(named: "backgroundColor") ?? UIColor.red
    static let switchColor = UIColor(named: "switchColor") ?? UIColor.blue
    static let gradientColor1 = UIColor(named: "gradientColor1") ?? UIColor.red
    static let gradientColor2 = UIColor(named: "gradientColor2") ?? UIColor.green
    static let gradientColor3 = UIColor(named: "gradientColor3") ?? UIColor.blue
    static let datePickerColor = UIColor(named: "datePickerColor") ?? UIColor.gray
    static let datePickerTintColor = UIColor(named: "datePickerTintColor") ?? UIColor.black
    static let searchTextFieldColor = UIColor(named: "searchTextFieldColor") ?? UIColor.gray
    static let ypGray = UIColor(named: "ypGray") ?? UIColor.gray
    static let ypWhite = UIColor(named: "ypWhite") ?? UIColor.white
    static let ypRed = UIColor(named: "ypRed") ?? UIColor.red
    static let ypBlack = UIColor(named: "ypBlack") ?? UIColor.black
    static let lightGray = UIColor(named: "lightGray") ?? UIColor.gray
    static let ypBlue = UIColor(named: "ypBlue") ?? UIColor.blue
    static let color1 = UIColor(named: "Color1") ?? UIColor.red
    static let color2 = UIColor(named: "Color2") ?? UIColor.red
    static let color3 = UIColor(named: "Color3") ?? UIColor.red
    static let color4 = UIColor(named: "Color4") ?? UIColor.red
    static let color5 = UIColor(named: "Color5") ?? UIColor.red
    static let color6 = UIColor(named: "Color6") ?? UIColor.red
    static let color7 = UIColor(named: "Color7") ?? UIColor.red
    static let color8 = UIColor(named: "Color8") ?? UIColor.red
    static let color9 = UIColor(named: "Color9") ?? UIColor.red
    static let color10 = UIColor(named: "Color10") ?? UIColor.red
    static let color11 = UIColor(named: "Color11") ?? UIColor.red
    static let color12 = UIColor(named: "Color12") ?? UIColor.red
    static let color13 = UIColor(named: "Color13") ?? UIColor.red
    static let color14 = UIColor(named: "Color14") ?? UIColor.red
    static let color15 = UIColor(named: "Color15") ?? UIColor.red
    static let color16 = UIColor(named: "Color16") ?? UIColor.red
    static let color17 = UIColor(named: "Color17") ?? UIColor.red
    static let color18 = UIColor(named: "Color18") ?? UIColor.red
    
    var hexString: String {
        let components = self.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        return String.init(
            format: "%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
    }
}

