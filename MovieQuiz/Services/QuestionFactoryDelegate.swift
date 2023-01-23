//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Евгений Ивойлов on 27.12.2022.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
    func didFailToLoadImage(with message: String)
}
