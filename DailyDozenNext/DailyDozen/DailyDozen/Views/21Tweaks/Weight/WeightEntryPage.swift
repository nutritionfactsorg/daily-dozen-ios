//
//  WeightEntryPage 2.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct WeightEntryPage: View {
    let date: Date
    @ObservedObject var viewModel: WeightEntryViewModel
   // @Binding var pendingWeights: [String: PendingWeight]
    @State private var amWeight: String = ""
    @State private var pmWeight: String = ""
    @State private var amTime: Date = Date()
    @State private var pmTime: Date = Date()
    @State private var unitType: UnitType = .fromUserDefaults()
    @State private var showClearAMConfirmation = false
    @State private var showClearPMConfirmation = false
    
    var body: some View {
            VStack(spacing: 0) {
                Form {
                    AMWeightSection(
                        date: date,
                        viewModel: viewModel,
                        amWeight: $amWeight,
                        amTime: $amTime,
                        unitType: unitType,
                        showClearConfirmation: $showClearAMConfirmation
                    )
                    PMWeightSection(
                        date: date,
                        viewModel: viewModel,
                        pmWeight: $pmWeight,
                        pmTime: $pmTime,
                        unitType: unitType,
                        showClearConfirmation: $showClearPMConfirmation
                    )
                }
                .alert("Clear AM Weight", isPresented: $showClearAMConfirmation) {
                    Button("Clear", role: .destructive) {
                        Task {
                            do {
                                try await HealthSynchronizer.shared.syncWeightClear(date: date, ampm: .am)
                                amWeight = ""
                                viewModel.updatePendingWeights(for: date, amWeight: amWeight, pmWeight: pmWeight, amTime: amTime, pmTime: pmTime)
                                let data = await viewModel.loadWeights(for: date, unitType: unitType) // 🟢 Changed: Use WeightEntryData
                                amWeight = data.amWeight
                                pmWeight = data.pmWeight
                                amTime = data.amTime
                                pmTime = data.pmTime
                                print("•Clear• AM weight cleared for \(date.datestampSid)")
                            } catch {
                                print("•Clear• AM clear error: \(error.localizedDescription)")
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Clear AM weight for \(date.formatted(date: .long, time: .omitted))?")
                }
                .alert("Clear PM Weight", isPresented: $showClearPMConfirmation) {
                    Button("Clear", role: .destructive) {
                        Task {
                            do {
                                try await HealthSynchronizer.shared.syncWeightClear(date: date, ampm: .pm)
                                pmWeight = ""
                                viewModel.updatePendingWeights(for: date, amWeight: amWeight, pmWeight: pmWeight, amTime: amTime, pmTime: pmTime)
                                let data = await viewModel.loadWeights(for: date, unitType: unitType) // 🟢 Changed: Use WeightEntryData
                                amWeight = data.amWeight
                                pmWeight = data.pmWeight
                                amTime = data.amTime
                                pmTime = data.pmTime
                                print("•Clear• PM weight cleared for \(date.datestampSid)")
                            } catch {
                                print("•Clear• PM clear error: \(error.localizedDescription)")
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Clear PM weight for \(date.formatted(date: .long, time: .omitted))?")
                }
            }
            .task {
                let data = await viewModel.loadWeights(for: date, unitType: unitType) // 🟢 Changed: Use WeightEntryData
                amWeight = data.amWeight
                pmWeight = data.pmWeight
                amTime = data.amTime
                pmTime = data.pmTime
                viewModel.updatePendingWeights(for: date, amWeight: amWeight, pmWeight: pmWeight, amTime: amTime, pmTime: pmTime)
            }
            .onChange(of: unitType) { _, newValue in // 🟢 Changed: Single-argument syntax
                Task {
                    let data = await viewModel.loadWeights(for: date, unitType: newValue) // 🟢 Changed: Use WeightEntryData
                    amWeight = data.amWeight
                    pmWeight = data.pmWeight
                    amTime = data.amTime
                    pmTime = data.pmTime
                }
            }
        }
    }

struct AMWeightSection: View {
    let date: Date
    @ObservedObject var viewModel: WeightEntryViewModel
    @Binding var amWeight: String
    @Binding var amTime: Date
    let unitType: UnitType
    @Binding var showClearConfirmation: Bool

    var body: some View {
        Section(header: Text("Morning Weight (AM)")) {
            WeightInputField( // 🟢 Changed: Extracted to subview
                           placeholder: "Weight (\(unitType == .metric ? "kg" : "lbs"))",
                           text: $amWeight,
                           onChange: { newValue in
                               if let value = Double(newValue.filter { !$0.isWhitespace }), value >= 0 {
                                   amWeight = newValue
                               } else if !newValue.isEmpty {
                                   amWeight = ""
                               }
                               viewModel.updatePendingWeights(for: date, amWeight: amWeight, pmWeight: "", amTime: amTime, pmTime: amTime)
                           }
                       )
            DatePicker("Time", selection: $amTime, displayedComponents: .hourAndMinute)
                .padding(.horizontal)
                .onChange(of: amTime) {
                    viewModel.updatePendingWeights(for: date, amWeight: amWeight, pmWeight: "", amTime: amTime, pmTime: amTime)
                }
            if !amWeight.isEmpty || viewModel.tracker(for: date).weightAM.dataweight_kg > 0 {
                Button("Clear AM Weight") {
                    showClearConfirmation = true
                }
                .foregroundColor(.blue)
            }
        }
    }
}

struct PMWeightSection: View {
    let date: Date
    @ObservedObject var viewModel: WeightEntryViewModel
    @Binding var pmWeight: String
    @Binding var pmTime: Date
    let unitType: UnitType
    @Binding var showClearConfirmation: Bool

    var body: some View {
        Section(header: Text("Evening Weight (PM)")) {
            TextField("Weight (\(unitType == .metric ? "kg" : "lbs"))", text: $pmWeight)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .onChange(of: pmWeight) { _, newValue in
                    if let value = Double(newValue.filter { !$0.isWhitespace }), value >= 0 {
                        pmWeight = newValue
                    } else if !newValue.isEmpty {
                        pmWeight = ""
                    }
                    viewModel.updatePendingWeights(for: date, amWeight: "", pmWeight: pmWeight, amTime: pmTime, pmTime: pmTime)
                }
            DatePicker("Time", selection: $pmTime, displayedComponents: .hourAndMinute)
                .padding(.horizontal)
                .onChange(of: pmTime) { _, _ in
                    viewModel.updatePendingWeights(for: date, amWeight: "", pmWeight: pmWeight, amTime: pmTime, pmTime: pmTime)
                }
            if !pmWeight.isEmpty || viewModel.tracker(for: date).weightPM.dataweight_kg > 0 { // 🟢 Changed: Fixed PM button condition
                Button("Clear PM Weight") {
                    showClearConfirmation = true
                }
                .foregroundColor(.red)
            }
        }
    }
}

struct WeightInputField: View {
    let placeholder: String
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
