//
//  ContentView.swift
//  SnakeGameApp
//
//  Created by Emir Okay on 4.11.2024.
//

import SwiftUI

struct ContentView: View {
	@StateObject private var viewModel = GameViewModel()
	@State private var showSettings = false

	var body: some View {
		VStack {
			
			HStack{
				Text("SCORE: \(viewModel.snakeBody.count - 1)").bold().padding()
				Spacer()
				Button("Settings") {
					showSettings = true
				}
			}
			.padding()
			
			Rectangle()
				.fill(Color.white)
				.frame(width: viewModel.mapSize, height: viewModel.mapSize)
				.border(Color.black, width: 0.5)
				.overlay {
					drawGrid()
					ForEach(viewModel.snakeBody.indices, id: \.self) { index in
						Rectangle()
							.frame(width: viewModel.cellSize, height: viewModel.cellSize)
							.foregroundColor(index == 0 ? .green : .blue)
							.position(x: viewModel.snakeBody[index].x + (viewModel.cellSize / 2), y: viewModel.snakeBody[index].y + (viewModel.cellSize / 2))
					}
					Rectangle()
						.frame(width: viewModel.cellSize, height: viewModel.cellSize)
						.foregroundColor(.red)
						.position(x: viewModel.foodPosition.x + (viewModel.cellSize / 2), y: viewModel.foodPosition.y + (viewModel.cellSize / 2))
				}
			
			VStack {
				DirectionButton(action: { if viewModel.direction != .down { viewModel.direction = .up } }, symbol: "arrowshape.up.fill").offset(y: +10)
				HStack(spacing: 65) {
					DirectionButton(action: { if viewModel.direction != .right { viewModel.direction = .left } }, symbol: "arrowshape.left.fill")
					DirectionButton(action: { if viewModel.direction != .left { viewModel.direction = .right } }, symbol: "arrowshape.right.fill")
				}
				DirectionButton(action: { if viewModel.direction != .up { viewModel.direction = .down } }, symbol: "arrowshape.down.fill").offset(y: -10)
			}
			.padding()
		}
		.alert(item: $viewModel.alertType) { alertType in
			switch alertType {
			case .gameOver:
				return Alert(title: Text("Game Over"), message: Text("You hit the wall!"), dismissButton: .default(Text("Restart")) { viewModel.restartGame() })
			case .winGame:
				return Alert(title: Text("You Win!"), message: Text("Congratulations! You filled the board."), dismissButton: .default(Text("Restart")) { viewModel.restartGame() })
			}
		}
		.sheet(isPresented: $showSettings, onDismiss: {
			viewModel.resumeGame()
		}) {
			SettingsView(cellSize: $viewModel.cellSize, timerInterval: $viewModel.timerInterval)
				.onAppear {
					viewModel.pauseGame()
				}
		}
	}
	
	private func drawGrid() -> some View {
		Path { path in
			for x in stride(from: viewModel.cellSize, through: viewModel.mapSize, by: viewModel.cellSize) {
				path.move(to: CGPoint(x: x, y: 0))
				path.addLine(to: CGPoint(x: x, y: viewModel.mapSize))
			}
			for y in stride(from: viewModel.cellSize, through: viewModel.mapSize, by: viewModel.cellSize) {
				path.move(to: CGPoint(x: 0, y: y))
				path.addLine(to: CGPoint(x: viewModel.mapSize, y: y))
			}
		}
		.stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
	}
}

#Preview {
	ContentView()
}
