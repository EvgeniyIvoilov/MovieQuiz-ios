import UIKit

final class MovieQuizViewController: UIViewController {
    
    let presenter = MovieQuizPresenter()
    var alertPresenter: AlertPresenter = AlertPresenter()
    var statisticService: StatisticService?
    
    // MARK: - UI
    
    @IBOutlet var questionButtons: [UIButton]!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Livecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        presenter.viewDidLoad()
        showLoadingIndicator()
        alertPresenter.controller = self
        statisticService = StatisticServiceImplementation()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didFailToLoadImage(with message: String) {
        showNetworkError(message: message)
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Private
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model: AlertModel = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            self.showLoadingIndicator()
        }
        alertPresenter.show(with: model)
    }
    
    func show(quiz step: QuizStepViewModel) {
        hideLoadingIndicator()
        UIView.transition(with: imageView, duration: 0.5, options: .transitionCrossDissolve) {
            self.imageView.image = step.image
        }
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
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
    
    func showAnswerResult(isCorrect: Bool) {
        
        if isCorrect == true {
            imageView.layer.borderColor = UIColor(.ypGreen)?.cgColor
            presenter.didAnswer(isCorrectAnswer: isCorrect)
        } else {
            imageView.layer.borderColor = UIColor(.ypRed)?.cgColor
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        presenter.showNextQuestionOrResults()
    }
}
