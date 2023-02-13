import UIKit

typealias MovieQuizViewProtocol = MovieQuizViewControllerProtocol & UIViewController

protocol MovieQuizPresenterProtocol {
    func viewDidLoad()
    func restartGame()
    func yesButtonClicked()
    func noButtonClicked()
}

final class MovieQuizPresenter: QuestionFactoryDelegate, MovieQuizPresenterProtocol {
    
    private var statisticService: StatisticService!
    private var questionFactory: QuestionFactoryProtocol
    private weak var viewController: MovieQuizViewProtocol?
    
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var alertPresenter: AlertPresenter = AlertPresenter()
    
    init(viewController:  MovieQuizViewProtocol, questionFactory: QuestionFactoryProtocol) {
        self.viewController = viewController
        self.questionFactory = questionFactory
    }
    
    // MARK: - MovieQuizPresenterProtocol
    
    func viewDidLoad() {
        alertPresenter.controller = viewController
        questionFactory.delegate = self
        questionFactory.loadData()
        statisticService = StatisticServiceImplementation()
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory.requestNextQuestion()
    }
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let answer: Bool = true
        self.proceedWithAnswer(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let answer: Bool = false
        self.proceedWithAnswer(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        viewController?.show(quiz: viewModel)
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didFailToLoadImage(with message: String) {
        viewController?.showNetworkError(message: message)
    }
    
    //MARK: - Private
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if (isCorrectAnswer) {
            correctAnswers += 1
        }
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
   private func proceedToNextQuestionOrResults() {
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
                self.questionFactory.requestNextQuestion()
                self.viewController?.hideImageBorder()
            })
            alertPresenter.show(with: model)
        } else {
            self.switchToNextQuestion()
            questionFactory.requestNextQuestion()
            self.viewController?.hideImageBorder()
        }
    }
    
    private func makeAlertMessage(_ result: String) -> String {
       guard let statisticService = statisticService else {
           return result
       }
       let countGamesText = "Колличество сыгранных квизов: \(statisticService.gamesCount)\n"
       let recordText = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\n"
       let totalAccuracyText = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
       let message = result + countGamesText + recordText + totalAccuracyText
       return message
   }
    
   private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
}
