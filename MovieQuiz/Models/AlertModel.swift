import UIKit

// MARK: - Models

/// модель показа алерта в конце игры
struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
