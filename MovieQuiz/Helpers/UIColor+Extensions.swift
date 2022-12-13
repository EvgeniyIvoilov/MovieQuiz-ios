import Foundation
import UIKit

extension UIColor {
    public enum YPColor: String {
        case ypGreen = "YP Green"
        case ypBackground = "YP BackGround"
        case ypBlack = "YP Black"
        case ypGray = "YP Gray"
        case ypRed = "YP Red"
        case ypWhite = "YP White"
    }
    public convenience init?(_ ypColor: YPColor) {
        self.init(named: ypColor.rawValue)
    }
}
