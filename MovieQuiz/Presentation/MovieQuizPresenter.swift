//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Евгений Ивойлов on 07.02.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var currentQuestionIndex: Int = 0
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var correctAnswers: Int = 0
    private var statisticService: StatisticService?
    private var questionFactory: QuestionFactoryProtocol? = {
        let factory =  QuestionFactory(moviesLoader: MoviesLoader(), delegate: nil)
        return factory
    }()
    
    private var alertPresenter: AlertPresenter = AlertPresenter()
    
    func viewDidLoad() {
        alertPresenter.controller = viewController
        questionFactory?.delegate = self
        questionFactory?.loadData()
        statisticService = StatisticServiceImplementation()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didFailToLoadImage(with message: String) {
        
    }
    
    // MARK: - ???
    
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
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if (isCorrectAnswer) { correctAnswers += 1}
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: self.questionsAmount)
            let resultText = correctAnswers == self.questionsAmount ?
            "Поздравляем, Вы ответили на 10 из 10!" :
            "Ваш результат: \(correctAnswers)/\(self.questionsAmount)\n"
            let message = makeAlertMessage(resultText)
            let model: AlertModel = AlertModel(title: "Этот раунд окончен", message: message, buttonText: "Сыграть еще раз!", completion: { [weak self] in
                guard let self = self else { return }
                self.restartGame()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
                self.viewController?.imageView.layer.masksToBounds = true
                self.viewController?.imageView.layer.borderWidth = 0
            })
            alertPresenter.show(with: model)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            self.viewController?.imageView.layer.masksToBounds = true
            self.viewController?.imageView.layer.borderWidth = 0
        }
        viewController?.questionButtons.forEach({$0.isEnabled = true})
    }
    
    func makeAlertMessage(_ result: String) -> String {
       guard let statisticService = statisticService else {
           return result
       }
       let countGamesText = "Колличество сыгранных квизов: \(statisticService.gamesCount)\n"
       let recordText = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\n"
       let totalAccuracyText = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
       let message = result + countGamesText + recordText + totalAccuracyText
       return message
   }
}
