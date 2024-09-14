import Foundation

enum Player: String {
    case human = "X"
    case ai = "O"
}

struct TicTacToeModel {
    private(set) var board: [String]
    private(set) var currentPlayer: Player
    private(set) var winner: Player?
    private(set) var isGameOver: Bool
    
    init() {
        board = Array(repeating: "", count: 9)
        currentPlayer = .human
        winner = nil
        isGameOver = false
    }
    
    mutating func makeMove(at index: Int) -> Bool {
        guard index >= 0 && index < 9 && board[index].isEmpty && !isGameOver else {
            return false
        }
        
        board[index] = currentPlayer.rawValue
        
        if checkForWin(player: currentPlayer) {
            winner = currentPlayer
            isGameOver = true
        } else if board.allSatisfy({ !$0.isEmpty }) {
            isGameOver = true
        } else {
            currentPlayer = (currentPlayer == .human) ? .ai : .human
        }
        
        return true
    }
    
    private func checkForWin(player: Player) -> Bool {
        let winPatterns = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],  // Rows
            [0, 3, 6], [1, 4, 7], [2, 5, 8],  // Columns
            [0, 4, 8], [2, 4, 6]              // Diagonals
        ]
        
        return winPatterns.contains { pattern in
            pattern.allSatisfy { board[$0] == player.rawValue }
        }
    }
    
    mutating func reset() {
        board = Array(repeating: "", count: 9)
        currentPlayer = .human
        winner = nil
        isGameOver = false
    }
}
