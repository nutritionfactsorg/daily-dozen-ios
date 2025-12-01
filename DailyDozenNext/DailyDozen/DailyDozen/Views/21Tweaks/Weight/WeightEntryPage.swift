//
//  WeightEntryPage 2.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

struct WeightEntryPage: View {
    let date: Date
    @ObservedObject var viewModel: SqlDailyTrackerViewModel
    @State private var amWeight: String = ""
    @State private var pmWeight: String = ""
    @State private var amTime: Date = Date()
    @State private var pmTime: Date = Date()
    @State private var unitType: UnitType = .fromUserDefaults()
    @State private var showClearAMConfirmation: Bool = false
    @State private var showClearPMConfirmation: Bool = false

    var body: some View {
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
                        var tracker = viewModel.tracker ?? SqlDailyTracker(date: date)
                        let record = SqlDataWeightRecord(date: date, weightType: .am, kg: 0, timeHHmm: "")
                        tracker.weightAM = record
                        try await HealthSynchronizer.shared.syncWeightClear(date: date, ampm: .am, tracker: tracker)
                        await viewModel.saveWeight(
                            record: record,
                            oldDatePsid: tracker.weightAM?.pidKeys.datestampSid,
                            oldAmpm: 0
                        )
                        amWeight = ""
                        let data = await viewModel.loadWeights(for: date, unitType: unitType)
                        await MainActor.run {
                            amWeight = data.amWeight
                            pmWeight = data.pmWeight
                            amTime = data.amTime
                            pmTime = data.pmTime
                        }
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
                        var tracker = viewModel.tracker ?? SqlDailyTracker(date: date)
                        let record = SqlDataWeightRecord(date: date, weightType: .pm, kg: 0, timeHHmm: "")
                        tracker.weightPM = record
                        try await HealthSynchronizer.shared.syncWeightClear(date: date, ampm: .pm, tracker: tracker)
                        await viewModel.saveWeight(
                            record: record,
                            oldDatePsid: tracker.weightPM?.pidKeys.datestampSid,
                            oldAmpm: 1
                        )
                        pmWeight = ""
                        let data = await viewModel.loadWeights(for: date, unitType: unitType)
                        await MainActor.run {
                            amWeight = data.amWeight
                            pmWeight = data.pmWeight
                            amTime = data.amTime
                            pmTime = data.pmTime
                        }
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
        @ObservedObject var viewModel: SqlDailyTrackerViewModel
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
                        Task {await viewModel.updatePendingWeights(for: date, amWeight: amWeight, pmWeight: "", amTime: amTime, pmTime: amTime)
                        }
                    }
                )
                DatePicker("Time", selection: $amTime, displayedComponents: .hourAndMinute)
                    .padding(.horizontal)
                .onChange(of: amTime) {
                    Task {
                        await viewModel.updatePendingWeights(for: date, amWeight: amWeight, pmWeight: "", amTime: amTime, pmTime: amTime)
                    }
                }
                if !amWeight.isEmpty || (viewModel.tracker?.weightAM?.dataweight_kg ?? 0) > 0 {
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
    @ObservedObject var viewModel: SqlDailyTrackerViewModel
    @Binding var pmWeight: String
    @Binding var pmTime: Date
    let unitType: UnitType
    @Binding var showClearConfirmation: Bool

    var body: some View {
        Section(header: Text("Evening Weight (PM)")) {
            WeightInputField(
                placeholder: "Weight (\(unitType == .metric ? "kg" : "lbs"))",
                text: $pmWeight,
                onChange: { newValue in
                    if let value = Double(newValue.filter { !$0.isWhitespace }), value >= 0 {
                        pmWeight = newValue
                    } else if !newValue.isEmpty {
                        pmWeight = ""
                    }
                    Task {
                        await viewModel.updatePendingWeights(for: date, amWeight: "", pmWeight: pmWeight, amTime: pmTime, pmTime: pmTime)
                    }
                }
                )
            DatePicker("Time", selection: $pmTime, displayedComponents: .hourAndMinute)
                .padding(.horizontal)
                .onChange(of: pmTime) {
                    Task { await viewModel.updatePendingWeights(for: date, amWeight: "", pmWeight: pmWeight, amTime: pmTime, pmTime: pmTime)
                    }
                }
            if !pmWeight.isEmpty || (viewModel.tracker?.weightAM?.dataweight_kg ?? 0) > 0 { // 🟢 Changed: Fixed PM button condition
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
