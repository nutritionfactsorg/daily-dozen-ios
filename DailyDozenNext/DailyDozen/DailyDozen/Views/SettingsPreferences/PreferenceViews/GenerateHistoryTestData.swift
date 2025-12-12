//
//  GenerateHistory.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//
//
//  Struct used purely to generate test data

import SwiftUI

struct GenerateHistoryTestDataView: View {
    @State private var isGenerating = false
    @State private var successMessage = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // 30 Days Button
                Button {
                    Task { await generateTestData(days: 30) }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text("30d")
                            .font(.caption.bold())
                    }
                    .frame(width: 55, height: 32)
                    .background(isGenerating ? .gray : .blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isGenerating)
                
                // 300 Days Button
                Button {
                    Task { await generateTestData(days: 300) }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.caption)
                        Text("300d")
                            .font(.caption.bold())
                    }
                    .frame(width: 60, height: 32)
                    .background(isGenerating ? .gray : .green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isGenerating)
            
                Button {
                    Task { await generateTestData(days: 1000) }
                } label: {
                HStack(spacing: 4) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.caption)
                    Text("1000d")
                        .font(.caption.bold())
                }
                .frame(width: 60, height: 32)
                .background(isGenerating ? .gray : .red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(isGenerating)
        }
            
            if isGenerating {
                ProgressView("Generating...")
                    .scaleEffect(0.8)
                    .frame(height: 16)
            }
            
            if !successMessage.isEmpty {
                Text(successMessage)
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func generateTestData(days: Int) async {
        isGenerating = true
        successMessage = ""
        errorMessage = ""
        
        print("🟢 •GEN• BEGIN GenerateHistoryView.generateTestData(\(days)) \(Date())")
        
        do {
            try await SqlDailyTrackerViewModel.shared.generateHistoryTestData(days: days)
            await MainActor.run {
                successMessage = "✅ \(days) days generated!"
            }
            print("🟢 •GEN• SUCCESS GenerateHistoryView.generateTestData(\(days)) \(Date())")
        } catch {
            await MainActor.run {
                errorMessage = "❌ \(error.localizedDescription)"
            }
            print("🔴 •GEN• ERROR GenerateHistoryView.generateTestData(\(days)): \(error)")
        }
        
        isGenerating = false
    }
}

#Preview {
    GenerateHistoryTestDataView()
        .frame(height: 80)
}
