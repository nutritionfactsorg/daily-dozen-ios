//
//  WeightEntryView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

struct PendingWeight {
    var amWeight: String
    var pmWeight: String
    var amTime: Date
    var pmTime: Date
}

import SwiftUI
//TBDz this page needs localization
struct WeightEntryView: View {
    @StateObject private var viewModel: WeightEntryViewModel
    @State private var currentDate: Date
    @Environment(\.dismiss) private var dismiss
    @State private var pendingWeights: [String: PendingWeight] = [:]
    
    init(initialDate: Date, viewModel: WeightEntryViewModel = WeightEntryViewModel()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._currentDate = State(initialValue: initialDate.startOfDay)
    }
    
    //TBDz:  determine if saving only to one decimal?  I think not?
    private func savePendingWeights() {
        print("savePendingWeights called with: \(pendingWeights.map { ($0.key, $0.value.amWeight, $0.value.pmWeight) })")
        for (dateSid, weights) in pendingWeights {
           // let amValue = Double(weights.amWeight.filter { !$0.isWhitespace })
            //let pmValue = Double(weights.pmWeight.filter { !$0.isWhitespace })
            let amValue = Double(weights.amWeight.filter { !$0.isWhitespace }).map { String(format: "%.1f", $0) }
            let pmValue = Double(weights.pmWeight.filter { !$0.isWhitespace }).map { String(format: "%.1f", $0) }
            print("Processing \(dateSid): AM \(String(describing: amValue)), PM \(String(describing: pmValue))")
            if (amValue != nil && Double(amValue!)! >= 0) || (pmValue != nil && Double(pmValue!)! >= 0) {
                guard let date = Date(datestampSid: dateSid) else {
//            if (amValue != nil && amValue! >= 0) || (pmValue != nil && pmValue! >= 0) {
//                guard let date = Date(datestampSid: dateSid) else {
                    print("Invalid dateSid: \(dateSid), skipping save")
                    continue
                }
                viewModel.saveWeight(
                    for: date,
                   // amWeight: amValue,
                   // pmWeight: pmValue,
                    amWeight: amValue.flatMap { Double($0) },
                    pmWeight: pmValue.flatMap { Double($0) },
                    amTime: weights.amTime,
                    pmTime: weights.pmTime
                )
                print("Called saveWeight for \(dateSid)")
            } else {
                print("No valid weights for \(dateSid), skipping")
            }
        }
        pendingWeights.removeAll() // Clear to prevent duplicate saves
        print("Cleared pendingWeights after save")
    }
  
    var body: some View {
        NavigationStack {
            TabView(selection: $currentDate) {
                ForEach(0...30, id: \.self) { offset in
                    let date = Date().startOfDay.adding(days: -offset)
                    WeightEntryPage(date: date, viewModel: viewModel, pendingWeights: $pendingWeights)
                        .tag(date)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: currentDate) { _, newDate in
                print("Date changed to: \(newDate.datestampSid)")
                savePendingWeights()
                if newDate > Date().startOfDay {
                    currentDate = Date().startOfDay
                }
            }
            .navigationTitle("Weight")
            .navigationBarBackButtonHidden(true) // Hide default back button
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") {
                        print("Back button tapped")
                        savePendingWeights()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        print("Today button tapped")
                        savePendingWeights()
                        currentDate = Date().startOfDay
                    }) {
                        Text("Today")
                    }
                }
            }
            .onDisappear {
                print("WeightEntryView dismissed")
                savePendingWeights()
            }
        }
    }
}

// Single page for weight entry
struct WeightEntryPage: View {
    let date: Date
    @ObservedObject var viewModel: WeightEntryViewModel
    @Binding var pendingWeights: [String: PendingWeight]
    @State private var amWeight: String = ""
    @State private var pmWeight: String = ""
    @State private var amTime: Date = Date()
    @State private var pmTime: Date = Date()
    @State private var unitType: UnitType = .fromUserDefaults()
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Date: \(date.datestampSid)")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.brandGreen) 
                .border(Color.gray, width: 1)
                .frame(width: 300, height: 30, alignment: .center)
                
            Form {
                Section(header: Text("Morning Weight (AM)")) {
                    TextField("Weight (\(unitType == .metric ? "kg" : "lbs"))", text: $amWeight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .onChange(of: amWeight) { _, newValue in
                            // Validate and format input
                            if let value = Double(newValue.filter { !$0.isWhitespace }), value >= 0 {
                                amWeight = newValue
                            } else if !newValue.isEmpty {
                                amWeight = "" // Clear invalid input
                            }
                            updatePendingWeights()
                        }
//                        .onSubmit {
//                            if let value = Double(amWeight), value >= 0 {
//                                amWeight = String(format: "%.1f", value)
//                            } else {
//                                amWeight = ""
//                            }
//                            updatePendingWeights()
//                        }
                    DatePicker("Time", selection: $amTime, displayedComponents: .hourAndMinute)
                        .padding(.horizontal)
                        .onChange(of: amTime) { _, _ in
                            updatePendingWeights()
                                                }
                }
                Section(header: Text("Evening Weight (PM)")) {
                    TextField("Weight (\(unitType == .metric ? "kg" : "lbs"))", text: $pmWeight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
//                        .onSubmit {
//                            if let value = Double(pmWeight), value >= 0 {
//                                pmWeight = String(format: "%.1f", value)
//                            } else {
//                                pmWeight = ""
//                            }
//                            updatePendingWeights()
//                        }
                        .onChange(of: pmWeight) { _, newValue in
                            // Validate and format input
                            if let value = Double(newValue.filter { !$0.isWhitespace }), value >= 0 {
                                pmWeight = newValue
                            } else if !newValue.isEmpty {
                                pmWeight = "" // Clear invalid input
                            }
                            updatePendingWeights()
                        }
                    DatePicker("Time", selection: $pmTime, displayedComponents: .hourAndMinute)
                        .padding(.horizontal)
                        .onChange(of: pmTime) { _, _ in
                               updatePendingWeights()
                      }

                }
            }
        }
        .onAppear {
            loadWeights()
            unitType = .fromUserDefaults()
            print("WeightEntryPage appeared for date: \(date.datestampSid), AM: \(amWeight), PM: \(pmWeight)")
        }
        .onChange(of: unitType) { _ in
            loadWeights()
        }
    }
    
    private func loadWeights() {
            let tracker = viewModel.tracker(for: date)
            let unitType = UnitType.fromUserDefaults()
            
            amWeight = tracker.weightAM.dataweight_kg > 0 ? String(format: "%.1f", unitType == .metric ? tracker.weightAM.dataweight_kg : tracker.weightAM.dataweight_kg * 2.204623) : ""
            pmWeight = tracker.weightPM.dataweight_kg > 0 ? String(format: "%.1f", unitType == .metric ? tracker.weightPM.dataweight_kg : tracker.weightPM.dataweight_kg * 2.204623) : ""
            
            // Parse time with reference date
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            
            if tracker.weightAM.dataweight_time.isEmpty {
                amTime = Date()
            } else if let timeDate = Date(datestampHHmm: tracker.weightAM.dataweight_time, referenceDate: date) {
                amTime = timeDate
            } else {
                amTime = Date()
                print("Failed to parse AM time: \(tracker.weightAM.dataweight_time)")
            }
            
            if tracker.weightPM.dataweight_time.isEmpty {
                pmTime = Date()
            } else if let timeDate = Date(datestampHHmm: tracker.weightPM.dataweight_time, referenceDate: date) {
                pmTime = timeDate
            } else {
                pmTime = Date()
                print("Failed to parse PM time: \(tracker.weightPM.dataweight_time)")
            }
            
            updatePendingWeights()
            print("Loaded weights for \(date.datestampSid): AM \(amWeight), PM \(pmWeight), AM Time \(amTime.formatted(date: .omitted, time: .shortened)), PM Time \(pmTime.formatted(date: .omitted, time: .shortened))")
        }
    
    private func updatePendingWeights() {
        print("Entered updatePendingWeights")
        if !amWeight.isEmpty || !pmWeight.isEmpty {
            pendingWeights[date.datestampSid] = PendingWeight(
                amWeight: amWeight,
                pmWeight: pmWeight,
                amTime: amTime,
                pmTime: pmTime
            )
            print("Updated pending weights for \(date.datestampSid): AM \(amWeight), PM \(pmWeight)")
        } else {
            pendingWeights.removeValue(forKey: date.datestampSid)
            print("Removed pending weights for \(date.datestampSid): no valid inputs")
        }
    }
}
// Preview
struct WeightEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WeightEntryView(initialDate: Date())
        }
    }
}
