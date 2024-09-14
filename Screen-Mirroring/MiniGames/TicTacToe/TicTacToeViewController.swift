import UIKit
import SnapKit
import Combine

final class TicTacToeViewController: UIViewController {
    private let viewModel = TicTacToeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var gameBoard: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 5
        return stack
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var newGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(R.string.localizable.new_Game.callAsFunction(), for: .normal)
        button.addTarget(self, action: #selector(newGameTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(gameBoard)
        view.addSubview(statusLabel)
        view.addSubview(newGameButton)
        
        gameBoard.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(300)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(gameBoard.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
        }
        
        newGameButton.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        for i in 0..<3 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 5
            
            for j in 0..<3 {
                let button = UIButton()
                button.backgroundColor = .lightGray
                button.setTitle("", for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .bold)
                button.tag = i * 3 + j
                button.addTarget(self, action: #selector(cellTapped(_:)), for: .touchUpInside)
                rowStack.addArrangedSubview(button)
            }
            
            gameBoard.addArrangedSubview(rowStack)
        }
    }
    
    private func bindViewModel() {
        viewModel.$statusMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.statusLabel.text = message
            }
            .store(in: &cancellables)
        
        viewModel.$model
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                self?.updateBoard(with: model.board)
            }
            .store(in: &cancellables)
        
        viewModel.$shouldOfferNewGame
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldOffer in
                if shouldOffer {
                    self?.offerNewGame()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateBoard(with board: [String]) {
        for (index, cell) in board.enumerated() {
            if let button = gameBoard.arrangedSubviews
                .flatMap({ $0 as? UIStackView })
                .flatMap({ $0.arrangedSubviews })[safe: index] as? UIButton {
                button.setTitle(cell, for: .normal)
            }
        }
    }
    
    private func offerNewGame() {
        let (title, message) = getTitleAndMessage()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.new_Game.callAsFunction(), style: .default) { [weak self] _ in
            self?.viewModel.resetGame()
        })
        alert.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: .cancel))
        present(alert, animated: true)
    }
    
    private func getTitleAndMessage() -> (String, String) {
        switch viewModel.statusMessage {
        case R.string.localizable.you_Win():
            return (R.string.localizable.congratulations(), R.string.localizable.you_Won_The_Game())
        case R.string.localizable.you_Lose():
            return (R.string.localizable.game_Over(), R.string.localizable.better_Luck_Next_Time())
        case R.string.localizable.its_A_Draw():
            return (R.string.localizable.its_A_Tie(), R.string.localizable.game_Ended_In_Draw())
        default:
            return (R.string.localizable.game_Over(), R.string.localizable.game_Has_Ended())
        }
    }
    
    @objc private func cellTapped(_ sender: UIButton) {
        viewModel.makeMove(at: sender.tag)
    }
    
    @objc private func newGameTapped() {
        viewModel.resetGame()
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
