//
//  GameViewModel.swift
//  SnakeGameApp
//
//  Created by Emir Okay on 4.11.2024.
//

import SwiftUI
import Combine

enum Direction { case up, down, left, right }

enum AlertType: Identifiable {
	case gameOver, winGame
	var id: UUID { UUID() }
}

struct DirectionButton: View {
	let action: () -> Void
	let symbol: String
	private let buttonSize: CGFloat = 70.0
	
	var body: some View {
		Button(action: action) {
			Image(systemName: symbol)
				.font(.largeTitle)
				.padding(10)
				.frame(width: buttonSize, height: buttonSize)
				.background(Color.black)
				.foregroundColor(.white)
				.cornerRadius(10)
		}
	}
}

class GameViewModel: ObservableObject {
	@Published var snakeBody: [(x: CGFloat, y: CGFloat)] = [(0.0, 0.0)]
	@Published var foodPosition: CGPoint = .zero
	@Published var direction: Direction = .right
	@Published var alertType: AlertType? = nil
	@Published var cellSize: CGFloat = 60.0
	@Published var timerInterval: Double = 0.4
	
	var mapSize: CGFloat {
		let screenSize = UIScreen.main.bounds.width - 30
		return screenSize - screenSize.truncatingRemainder(dividingBy: cellSize)
	}
	
	private var maxCells: Int {
		let gridCount = Int(mapSize / cellSize)
		return gridCount * gridCount
	}
	
	private var timer: AnyCancellable?

	init() {
		startGame()
	}
	
	func startGame() {
		snakeBody = [(0.0, 0.0)]
		direction = .right
		foodPosition = randomFoodPosition()
		alertType = nil
		startTimer()
	}
	
	func changeCellSize(to newSize: CGFloat) {
		cellSize = newSize
		restartGame()
	}
	
	func changeTimerInterval(to interval: Double) {
		timerInterval = interval
		startTimer()
	}
	
	private func startTimer() {
		timer?.cancel()
		timer = Timer.publish(every: timerInterval, on: .main, in: .common)
			.autoconnect()
			.sink { [weak self] _ in
				guard let self = self else { return }
				if self.alertType == nil {
					self.moveSnake()
					self.checkCollision()
				}
			}
	}
	
	func pauseGame() {
		timer?.cancel()
	}
	
	func resumeGame() {
		startTimer()
	}
	
	func moveSnake() {
		let newHead = nextPosition(for: snakeBody[0])
		if isInBounds(newHead) {
			snakeBody.insert(newHead, at: 0)
			if CGPoint(x: newHead.x, y: newHead.y) == foodPosition {
				handleFoodConsumption()
			} else {
				snakeBody.removeLast()
			}
		} else {
			alertType = .gameOver
		}
	}

	private func nextPosition(for position: (x: CGFloat, y: CGFloat)) -> (x: CGFloat, y: CGFloat) {
		var newPosition = position
		switch direction {
		case .up:    newPosition.y -= cellSize
		case .down:  newPosition.y += cellSize
		case .left:  newPosition.x -= cellSize
		case .right: newPosition.x += cellSize
		}
		return newPosition
	}
	
	private func isInBounds(_ position: (x: CGFloat, y: CGFloat)) -> Bool {
		return position.x >= 0 && position.x < mapSize && position.y >= 0 && position.y < mapSize
	}
	
	private func handleFoodConsumption() {
		if snakeBody.count == maxCells {
			alertType = .winGame
		} else {
			spawnFood()
		}
	}
	
	private func checkCollision() {
		let head = snakeBody[0]
		for segment in snakeBody.dropFirst() {
			if segment.x == head.x && segment.y == head.y {
				alertType = .gameOver
				break
			}
		}
	}
	
	private func spawnFood() {
		foodPosition = randomFoodPosition()
	}
	
	private func randomFoodPosition() -> CGPoint {
		let gridCount = Int(mapSize / cellSize)
		var randomX: CGFloat
		var randomY: CGFloat
		repeat {
			randomX = CGFloat(Int.random(in: 0..<gridCount)) * cellSize
			randomY = CGFloat(Int.random(in: 0..<gridCount)) * cellSize
		} while snakeBody.contains(where: { $0.x == randomX && $0.y == randomY })
		
		return CGPoint(x: randomX, y: randomY)
	}
	
	func restartGame() {
		snakeBody = [(0.0, 0.0)]
		direction = .right
		foodPosition = randomFoodPosition()
		alertType = nil
	}
}
