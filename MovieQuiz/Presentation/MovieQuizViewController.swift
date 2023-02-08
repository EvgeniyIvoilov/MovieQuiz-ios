import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private let presenter = MovieQuizPresenter()
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol? = QuestionFactory(moviesLoader: MoviesLoader(), delegate: nil)
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter = AlertPresenter()
    private var statisticService: StatisticService?
    // MARK: - UI
    
    @IBOutlet var questionButtons: [UIButton]!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Livecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        questionFactory?.delegate = self
        showLoadingIndicator()
        questionFactory?.loadData()
        alertPresenter.controller = self
        statisticService = StatisticServiceImplementation()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadImage(with message: String) {
        showNetworkError(message: message)
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    // MARK: - Private
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() 
        let model: AlertModel = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.loadData()
            self.showLoadingIndicator()
        }
        alertPresenter.show(with: model)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        UIView.transition(with: imageView, duration: 0.5, options: .transitionCrossDissolve) {
            self.imageView.image = step.image
        }
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
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
    
        func showAnswerResult(isCorrect: Bool) {
        
        if isCorrect == true {
            imageView.layer.borderColor = UIColor(.ypGreen)?.cgColor
            correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor(.ypRed)?.cgColor
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
            let resultText = correctAnswers == presenter.questionsAmount ?
            "Поздравляем, Вы ответили на 10 из 10!" :
            "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)\n"
            let message = makeAlertMessage(resultText)
            let model: AlertModel = AlertModel(title: "Этот раунд окончен", message: message, buttonText: "Сыграть еще раз!", completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
                self.imageView.layer.masksToBounds = true
                self.imageView.layer.borderWidth = 0
            })
            alertPresenter.show(with: model)
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 0
        }
        questionButtons.forEach({$0.isEnabled = true})
    }
}
