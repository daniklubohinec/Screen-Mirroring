import Foundation
import Combine

final class TicTacToeViewModel {
    @Published private(set) var model: TicTacToeModel
    @Published private(set) var statusMessage: String
    @Published private(set) var shouldOfferNewGame: Bool = false
    
    init() {
        model = TicTacToeModel()
        statusMessage = R.string.localizable.your_Turn()
    }
    
    func makeMove(at index: Int) {
        guard model.makeMove(at: index) else { return }
        
        updateStatusMessage()
        
        if !model.isGameOver && model.currentPlayer == .ai {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.makeAIMove()
            }
        }
    }
    
    private func makeAIMove() {
        guard let emptyCell = model.board.indices.filter({ model.board[$0].isEmpty }).randomElement() else { return }
        
        _ = model.makeMove(at: emptyCell)
        updateStatusMessage()
    }
    
    private func updateStatusMessage() {
        if let winner = model.winner {
            statusMessage = winner == .human ? R.string.localizable.you_Win() : R.string.localizable.you_Lose()
            shouldOfferNewGame = true
        } else if model.isGameOver {
            statusMessage = R.string.localizable.its_A_Draw()
            shouldOfferNewGame = true
        } else {
            statusMessage = model.currentPlayer == .human ? R.string.localizable.your_Turn() : R.string.localizable.ai_Is_Thinking()
            shouldOfferNewGame = false
        }
    }
    
    func resetGame() {
        model.reset()
        statusMessage = R.string.localizable.your_Turn()
        shouldOfferNewGame = false
    }
}
