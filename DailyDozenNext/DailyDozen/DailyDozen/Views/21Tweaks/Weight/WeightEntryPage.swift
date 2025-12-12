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
    //@EnvironmentObject var viewModel: SqlDailyTrackerViewModel
    @State private var amWeight: String = ""
    @State private var pmWeight: String = ""
    @State private var amTime: Date = Date()
    @State private var pmTime: Date = Date()
    @State private var unitType: UnitType = .fromUserDefaults()
    @State private var showClearAMConfirmation: Bool = false
    @State private var showClearPMConfirmation: Bool = false
    @State private var saveTask: Task<Void, Never>?
    
//    private func clearPMWeight() async {
//        do {
//            let tracker = viewModel.tracker ?? SqlDailyTracker(date: date.startOfDay)
//            let record = SqlDataWeightRecord(date: date.startOfDay, weightType: .pm, kg: 0, timeHHmm: "")
//            var updatedTracker = tracker
//            updatedTracker.weightPM = record
//            try await HealthSynchronizer.shared.syncWeightClear(date: date, ampm: .pm, tracker: updatedTracker)
//            await viewModel.saveWeight(
//                record: record,
//                oldDatePsid: tracker.weightPM?.pidKeys.datestampSid,
//                oldAmpm: 1
//            )
//            await MainActor.run {
//                pmWeight = ""
//                let data = await viewModel.loadWeights(for: date, unitType: unitType)
//                amWeight = data.amWeight == 0 ? "" : "\(data.amWeight)"
//                pmWeight = data.pmWeight == 0 ? "" : "\(data.pmWeight)"
//                amTime = data.amTime
//                pmTime = data.pmTime
//            }
//            print("•Clear• PM weight cleared for \(date.datestampSid)")
//        } catch {
//            print("•Clear• PM clear error: \(error.localizedDescription)")
//        }
//    }
    
    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 600_000_000) // 0.6s
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
               // viewModel: viewModel,
                amWeight: $amWeight,
                amTime: $amTime,
                pmWeight: $pmWeight,
                pmTime: $pmTime,
                unitType: unitType,
                showClearConfirmation: $showClearAMConfirmation,
                onSave: scheduleSave  // ← Pass it down
            )
            PMWeightSection(
                date: date,
               // viewModel: viewModel,
                pmWeight: $pmWeight,
                pmTime: $pmTime,
                amWeight: $amWeight,
                amTime: $amTime,
                unitType: unitType,
                showClearConfirmation: $showClearPMConfirmation,
                onSave: scheduleSave  // ← Pass it down
            )
        }
        .alert("Clear AM Weight", isPresented: $showClearAMConfirmation) {
            Button("Clear", role: .destructive) {
                Task {
                    if viewModel.tracker(for: date).weightAM != nil {
                        await viewModel.deleteWeight(for: date, weightType: .am)
                    }
                    do {
                        try await HealthSynchronizer.shared.syncWeightClear(date: date, ampm: .am)
                        await MainActor.run {
                            amWeight = ""
                            amTime = Date()
                            var tracker = viewModel.tracker(for: date)
                            tracker.weightAM = nil  // Clears weight AND time
                            viewModel.updateTrackerInArray(tracker)
                            print("🟢 •Clear• AM tracker cleared (weight and time nil)")
                        }
                      //  await viewModel.updatePendingWeights(for: date, amWeight: "", pmWeight: pmWeight, amTime: Date.distantPast, pmTime: pmTime)
                    } catch {
                        print("•Clear• AM error: \(error.localizedDescription)")
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("history_data_alert_clear \(date.formatted(date: .long, time: .omitted))?")
        }
        .alert("Clear PM Weight", isPresented: $showClearPMConfirmation) {
            Button("Clear", role: .destructive) {
                Task {
                    if viewModel.tracker(for: date).weightPM != nil {
                        await viewModel.deleteWeight(for: date, weightType: .pm)
                    }
                    do {
                        try await HealthSynchronizer.shared.syncWeightClear(date: date, ampm: .pm)
                        await MainActor.run {
                            pmWeight = ""
                            pmTime = Date()
                            var tracker = viewModel.tracker(for: date)
                            tracker.weightPM = nil  // Clears weight AND time
                            viewModel.updateTrackerInArray(tracker)
                            print("🟢 •Clear• PM tracker cleared (weight and time nil)")
                        }
                       // await viewModel.updatePendingWeights(for: date, amWeight: amWeight, pmWeight: "", amTime: amTime, pmTime: Date.distantPast)
                    } catch {
                        print("•Clear• PM error: \(error.localizedDescription)")
                    }
                } //Task
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
//        .onAppear {
//            UITableView.appearance().keyboardDismissMode = .interactive  // ← ADD THIS   TBDz just for simulator keyboard error?
//        }
    }
}
    
    struct AMWeightSection: View {
        let date: Date
        private let viewModel = SqlDailyTrackerViewModel.shared
        @Binding var amWeight: String
        @Binding var amTime: Date
        @Binding var pmWeight: String
        @Binding var pmTime: Date
        let unitType: UnitType
        @Binding var showClearConfirmation: Bool
        let onSave: () -> Void
        
        var body: some View {
            Section(header: Text("weight_entry_morning")) {
                WeightInputField2( // 🟢 Changed: Extracted to subview
                    placeholder: "(\(unitType == .metric ? "kg" : "lbs"))",
                    text: $amWeight,
                    onChange: { newValue in
                        
                        if let value = Double(newValue.filter { !$0.isWhitespace }), value >= 0 {
                            amWeight = newValue
                        } else if !newValue.isEmpty {
                            amWeight = ""
                        }
//                        Task {await viewModel.updatePendingWeights(for: date, amWeight: amWeight, pmWeight: "", amTime: amTime, pmTime: amTime)
//                        }
                        onSave()
                    }
                )
                DatePicker("weight_entry_time", selection: $amTime, displayedComponents: .hourAndMinute)
                    .padding(.horizontal)
                .onChange(of: amTime) {
//                    Task {
//                        await viewModel.updatePendingWeights(
//                         for: date,
//                         amWeight: amWeight,
//                         pmWeight: pmWeight,
//                         amTime: amTime,
//                         pmTime: pmTime)
//                    }
                    onSave()
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
    private let viewModel = SqlDailyTrackerViewModel.shared
    @Binding var pmWeight: String
    @Binding var pmTime: Date
    @Binding var amWeight: String
    @Binding var amTime: Date
    let unitType: UnitType
    @Binding var showClearConfirmation: Bool
    let onSave: () -> Void

    var body: some View {
        
        Section(header: Text("weight_entry_evening")) {
            WeightInputField2(
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
//                    Task {
//                        await viewModel.updatePendingWeights(for: date, amWeight: "", pmWeight: pmWeight, amTime: pmTime, pmTime: pmTime)
//                    }
                }
                )
            DatePicker("Time", selection: $pmTime, displayedComponents: .hourAndMinute)
                .padding(.horizontal)
                .onChange(of: pmTime) {
//                    Task { await viewModel.updatePendingWeights(
//                        for: date,
//                        amWeight: amWeight,
//                        pmWeight: pmWeight,
//                        amTime: amTime,
//                        pmTime: pmTime)
//                    }
                    onSave()
                }
            if !pmWeight.isEmpty || (viewModel.tracker?.weightPM?.dataweight_kg ?? 0) > 0 { // 🟢 Changed: Fixed PM button condition
                Button("Clear PM Weight") {
                    showClearConfirmation = true
                }
                .foregroundColor(.red)
            }
        }
    }
}

//struct WeightInputField: View {
//    let placeholder: String
//    @Binding var text: String
//    let onChange: (String) -> Void
//
//    var body: some View {
//        TextField(placeholder, text: $text)
//            .keyboardType(.decimalPad)
//            .textFieldStyle(.roundedBorder)
//            .padding(.horizontal)
//            .onChange(of: text) { _, newValue in // 🟢 Changed: Single-argument syntax
//                onChange(newValue)
//            }
//    }
//}

struct WeightInputField2: View {
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
