import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: UIViewController, MovieQuizViewControllerProtocol {
    func hideImageBorder() {
        
    }
    
    var showQuizStepCalled = false
    var showQuizStepParametrs: QuizStepViewModel?
    
    func show(quiz step: QuizStepViewModel) {
        showQuizStepCalled = true
        showQuizStepParametrs = step
    }
    
    func show(quiz result: QuizResultsViewModel) {
    
    }
    
    var highlightImageBorderCalled = false
    func highlightImageBorder(isCorrectAnswer: Bool) {
        highlightImageBorderCalled = true
    }
    
    func showLoadingIndicator() {
    
    }
    var hideLoadingIndicatorCalled = false
    func hideLoadingIndicator() {
        hideLoadingIndicatorCalled = true
    }
    var showNetworkErrorCalled = false
    func showNetworkError(message: String) {
        showNetworkErrorCalled = true
    }
}

final class QuestionFactoryMock: QuestionFactoryProtocol {
    var delegate: MovieQuiz.QuestionFactoryDelegate?
    
    var requestNextQuestionCalled = false
    func requestNextQuestion() {
        requestNextQuestionCalled = true
    }
    
    var loadDataCalled = false
    func loadData() {
        loadDataCalled = true
    }
}


final class MovieQuizPresenterTests: XCTestCase {
    
    var sut: MovieQuizPresenter!
    
    var viewControllerMock: MovieQuizViewControllerMock!
    var questionFactoryMock: QuestionFactoryMock!
    
    override func setUp() {
        super.setUp()
        viewControllerMock = MovieQuizViewControllerMock()
        questionFactoryMock = QuestionFactoryMock()
        sut = MovieQuizPresenter(viewController: viewControllerMock,
                                 questionFactory: questionFactoryMock)
    }
    
    override func tearDown() {
        sut = nil
        viewControllerMock = nil
        questionFactoryMock = nil
        super.tearDown()
    }
    
    func testDidReceiveNextQuestion() throws {
        // given
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        
        // when
        sut.didReceiveNextQuestion(question: question)
        let viewModel = viewControllerMock.showQuizStepParametrs
        
        // then
        XCTAssertNotNil(viewModel?.image)
        XCTAssertEqual(viewModel?.question, "Question Text")
        XCTAssertEqual(viewModel?.questionNumber, "1/10")
        XCTAssertTrue(viewControllerMock.showQuizStepCalled)
    }
    
    func testViewDidLoad() {
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertNotNil(questionFactoryMock.delegate)
        XCTAssertTrue(questionFactoryMock.loadDataCalled)
    }
    
    func testRestartGame() {
        // given
        
        // when
        sut.restartGame()
        // then
        XCTAssertTrue(questionFactoryMock.requestNextQuestionCalled)
    }
    
    func testYesButtonClicked() {
        // given
        let question = QuizQuestion(image: Data(), text: "Test", correctAnswer: true)
        
        // when
        sut.didReceiveNextQuestion(question: question)
        sut.yesButtonClicked()
        
        // then
        XCTAssertTrue(viewControllerMock.highlightImageBorderCalled)
    }
    
    func testNoButtonClicked() {
        // given
        let question = QuizQuestion(image: Data(), text: "Test", correctAnswer: true)
        
        // when
        sut.didReceiveNextQuestion(question: question)
        sut.noButtonClicked()
        
        // then
        XCTAssertTrue(viewControllerMock.highlightImageBorderCalled)
    }
    
    func testDidLoadDataFromServer() {
        // given
        
        // when
        sut.didLoadDataFromServer()
        // then
        XCTAssertTrue(viewControllerMock.hideLoadingIndicatorCalled)
        XCTAssertTrue(questionFactoryMock.requestNextQuestionCalled)
    }
    
    func testDidFailToLoadData() {
        // given
        let errorStub = TestError.someError
        // when
        sut.didFailToLoadData(with: errorStub)
        // then
        XCTAssertTrue(viewControllerMock.showNetworkErrorCalled)
    }
    
    func testDidFailToLoadImage() {
        // given
        let message = "test"
        // when
        sut.didFailToLoadImage(with: message)
        // then
        XCTAssertTrue(viewControllerMock.showNetworkErrorCalled)
    }
}

enum TestError: Error {
    case someError
}


