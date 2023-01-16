import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol? = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter = AlertPresenter()
    private var statisticService: StatisticService?
    // MARK: - UI
    
    @IBOutlet var questionButtons: [UIButton]!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    
    // MARK: - Livecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory?.delegate = self
        questionFactory?.requestNextQuestion()
        alertPresenter.controller = self
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
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let answer: Bool = true
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
        questionButtons.forEach { $0.isEnabled = false }
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let answer: Bool = false
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
        sender.isEnabled = false
        
        for questionButton in questionButtons {
            questionButton.isEnabled = false
        }
        questionButtons.forEach { $0.isEnabled = false }
    }
    
    // MARK: - Private
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
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
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        
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
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            let resultText = correctAnswers == questionsAmount ?
            "Поздравляем, Вы ответили на 10 из 10!" :
            "Ваш результат: \(correctAnswers)/\(questionsAmount)\n"
            let message = makeAlertMessage(resultText)
            let model: AlertModel = AlertModel(title: "Этот раунд окончен", message: message, buttonText: "Сыграть еще раз!", completion: { [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
                self.imageView.layer.masksToBounds = true
                self.imageView.layer.borderWidth = 0
            })
            alertPresenter.show(with: model)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 0
        }
        questionButtons.forEach({$0.isEnabled = true})
    }
}
