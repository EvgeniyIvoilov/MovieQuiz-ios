//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Евгений Ивойлов on 28.12.2022.
//

import UIKit

class AlertPresenter {
    
    weak var controller: UIViewController?
    
    func show(with model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText,
                                   style: .default,
                                   handler: { _ in model.completion() })
        alert.addAction(action)
        alert.view.accessibilityIdentifier = "EndGame"
        controller?.present(alert, animated: true, completion: nil)
    }
}
