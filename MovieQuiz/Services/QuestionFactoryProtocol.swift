//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Евгений Ивойлов on 26.12.2022.
//

import Foundation

protocol QuestionFactoryProtocol {
    var delegate: QuestionFactoryDelegate? { get set }
    func requestNextQuestion()
    
}


