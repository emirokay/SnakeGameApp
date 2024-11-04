//
//  SettingsView.swift
//  SnakeGameApp
//
//  Created by Emir Okay on 4.11.2024.
//
import SwiftUI

struct SettingsView: View {
	@Binding var cellSize: CGFloat
	@Binding var timerInterval: Double
	
	var body: some View {
		VStack(spacing: 20) {
			Text("Settings").font(.title).padding()
			
			HStack {
				Text("Map Size: ")
				Picker("", selection: $cellSize) {
					Text("Small").tag(CGFloat(40))
					Text("Medium").tag(CGFloat(60))
					Text("Large").tag(CGFloat(80))
				}
				.pickerStyle(.segmented)
			}
			
			HStack {
				Text("Speed: ")
				Picker("", selection: $timerInterval) {
					Text("Slow").tag(Double(0.5))
					Text("Medium").tag(Double(0.3))
					Text("Fast").tag(Double(0.1))
				}
				.pickerStyle(.segmented)
			}
			
			Spacer()
		}
		.padding()
	}
}

#Preview {
	ContentView()
}
