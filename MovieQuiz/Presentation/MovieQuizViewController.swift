import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
   
    private lazy var presenter: MovieQuizPresenterProtocol = {
        MovieQuizPresenter(viewController: self,
                           questionFactory: QuestionFactory(moviesLoader: MoviesLoader(), delegate: nil))
    }()
    private let alertPresenter: AlertPresenter = AlertPresenter()
    
    @IBOutlet private var questionButtons: [UIButton]!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Livecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        showLoadingIndicator()
        alertPresenter.controller = self
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
        questionButtons.forEach { $0.isEnabled = false }
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
        sender.isEnabled = false
        for questionButton in questionButtons {
            questionButton.isEnabled = false
        }
        questionButtons.forEach { $0.isEnabled = false }
    }
    
    // MARK: - MovieQuizViewControllerProtocol
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor(.ypGreen)?.cgColor : UIColor(.ypRed)?.cgColor
    }
    
    func hideImageBorder() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        questionButtons.forEach({$0.isEnabled = true})

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
}
