//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Евгений Ивойлов on 07.02.2023.
//

import UIKit

final class MovieQuizPresenter {
    
    private var currentQuestionIndex: Int = 0
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let answer: Bool = true
        viewController?.showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
        viewController?.questionButtons.forEach { $0.isEnabled = false }
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let answer: Bool = false
        viewController?.showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
        //sender.isEnabled = false
        
        for questionButton in viewController!.questionButtons {
            questionButton.isEnabled = false
        }
        viewController?.questionButtons.forEach { $0.isEnabled = false }
    }
    
    // MARK: - ???
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
        func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
}
