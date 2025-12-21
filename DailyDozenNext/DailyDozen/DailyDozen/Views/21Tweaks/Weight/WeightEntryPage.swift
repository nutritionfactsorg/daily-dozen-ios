//
//  WeightEntryPage 2.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct WeightEntryPage: View {
    let date: Date
    private let viewModel = SqlDailyTrackerViewModel.shared
    
    @State private var amWeight: String = ""
    @State private var pmWeight: String = ""
    @State private var amTime: Date = Date()
    @State private var pmTime: Date = Date()
    @State private var unitType: UnitType = .fromUserDefaults()
    
    @State private var showClearAMConfirmation = false
    @State private var showClearPMConfirmation = false
    
    @State private var saveTask: Task<Void, Never>?
    
    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 600_000_000)
            await viewModel.updatePendingWeights(
                for: date,
                amWeight: amWeight,
                pmWeight: pmWeight,
                amTime: amTime,
                pmTime: pmTime
            )
        }
    }
    
    var body: some View {
        Form {
            AMWeightSection(
                date: date,
                amWeight: $amWeight,
                amTime: $amTime,
                pmWeight: $pmWeight,
                pmTime: $pmTime,
                showClearConfirmation: $showClearAMConfirmation,
                unitType: unitType,
                onSave: scheduleSave
            )
            
            PMWeightSection(
                date: date,
                pmWeight: $pmWeight,
                pmTime: $pmTime,
                amWeight: $amWeight,
                amTime: $amTime,
                showClearConfirmation: $showClearPMConfirmation,
                unitType: unitType,
                onSave: scheduleSave
            )
        }
        .confirmationDialog("weight_entry_morning", isPresented: $showClearAMConfirmation, titleVisibility: .visible) {
            Button("weight_entry_clear", role: .destructive) {
                saveTask?.cancel()
                Task {
                    await viewModel.deleteWeight(for: date, weightType: .am)
                    let data = await viewModel.loadWeights(for: date, unitType: unitType)
                    await MainActor.run {
                        amWeight = data.amWeight
                        pmWeight = data.pmWeight
                        amTime = data.amTime
                        pmTime = data.pmTime
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("history_data_alert_clear \(date.formatted(date: .long, time: .omitted))?")
        }
        .confirmationDialog("weight_entry_evening", isPresented: $showClearPMConfirmation, titleVisibility: .visible) {
            Button("weight_entry_clear", role: .destructive) {
                saveTask?.cancel()
                Task {
                    await viewModel.deleteWeight(for: date, weightType: .pm)
                    let data = await viewModel.loadWeights(for: date, unitType: unitType)
                    await MainActor.run {
                        amWeight = data.amWeight
                        pmWeight = data.pmWeight
                        amTime = data.amTime
                        pmTime = data.pmTime
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("history_data_alert_clear \(date.formatted(date: .long, time: .omitted))?")
        }
        .task {
            let data = await viewModel.loadWeights(for: date, unitType: unitType)
            await MainActor.run {
                amWeight = data.amWeight
                pmWeight = data.pmWeight
                amTime = data.amTime
                pmTime = data.pmTime
            }
        }
        .onChange(of: unitType) { _, newValue in
            Task {
                let data = await viewModel.loadWeights(for: date, unitType: newValue)
                await MainActor.run {
                    amWeight = data.amWeight
                    pmWeight = data.pmWeight
                    amTime = data.amTime
                    pmTime = data.pmTime
                }
            }
        }
    }
}

struct AMWeightSection: View {
    let date: Date
    private let viewModel = SqlDailyTrackerViewModel.shared
    @Binding var amWeight: String
    @Binding var amTime: Date
    @Binding var pmWeight: String
    @Binding var pmTime: Date
    @Binding var showClearConfirmation: Bool
    let unitType: UnitType
    let onSave: () -> Void
   // let onClearAM: () -> Void
    
    var body: some View {
        Section(header: Text("weight_entry_morning")) {
            WeightInputField( // 🟢 Changed: Extracted to subview
                placeholder: "(\(unitType == .metric ? "kg" : "lbs"))",
                text: $amWeight,
                onChange: { newValue in
                    
                    if let value = Double(newValue.filter { !$0.isWhitespace }), value >= 0 {
                        amWeight = newValue
                    } else if !newValue.isEmpty {
                        amWeight = ""
                    }
                    
                    onSave()
                }
            )
            DatePicker("weight_entry_time", selection: $amTime, in: date.userDisplayStartOfDay...date.userEndOfAM, displayedComponents: .hourAndMinute)
                .padding(.horizontal)
                .onChange(of: amTime) {
                    //
                    onSave()
                }
            if !amWeight.isEmpty || viewModel.tracker(for: date).weightAM != nil {
                HStack {
                    Spacer()
                    Button("Clear AM Weight") {  // or localized key if you add it
                        showClearConfirmation = true
                    }
                    .buttonStyle(.borderless)
                    Spacer()
                }
            }
        }
    }
}

struct PMWeightSection: View {
    let date: Date
    private let viewModel = SqlDailyTrackerViewModel.shared
    @Binding var pmWeight: String
    @Binding var pmTime: Date
    @Binding var amWeight: String
    @Binding var amTime: Date
    @Binding var showClearConfirmation: Bool
    let unitType: UnitType
    
    let onSave: () -> Void
    
    var body: some View {
        
        Section(header: Text("weight_entry_evening")) {
            WeightInputField(
                placeholder: "(\(unitType == .metric ? "kg" : "lbs"))",
                // placeholder: keyString,
                // placeholder: String(localized:key, comment: "Daily time scale"),
                text: $pmWeight,
                onChange: { newValue in
                    if let value = Double(newValue.filter { !$0.isWhitespace }), value >= 0 {
                        pmWeight = newValue
                    } else if !newValue.isEmpty {
                        pmWeight = ""
                    }
                    onSave()
                    //
                }
            )
            DatePicker("weight_entry_time", selection: $pmTime, in: date.userNoon...date.userEndOfDay, displayedComponents: .hourAndMinute)
                .padding(.horizontal)
                .onChange(of: pmTime) {
                    //
                    onSave()
                }
            if !pmWeight.isEmpty || viewModel.tracker(for: date).weightPM != nil { // 🟢 Changed: Fixed PM button condition
                HStack {
                    Spacer()
                    Button("Clear PM Weight") {  // or localized key if you add it
                        showClearConfirmation = true
                    }
                    .buttonStyle(.borderless)
                    Spacer()
                }
            }
        }
    }
}

struct WeightInputField: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String
    let onChange: (String) -> Void
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(.decimalPad)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
            .onChange(of: text) { _, newValue in // 🟢 Changed: Single-argument syntax
                onChange(newValue)
            }
    }
}

#Preview {
    
    WeightEntryPage(date: Date.now)
        .environment(\.locale, .init(identifier: "fr"))
}
