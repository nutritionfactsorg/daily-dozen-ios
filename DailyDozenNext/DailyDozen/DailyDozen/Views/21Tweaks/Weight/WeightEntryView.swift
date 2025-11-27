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
    @StateObject private var viewModel = WeightEntryViewModel()
   // @State private var currentDate: Date = Date().startOfDay
    
    @State private var currentDate: Date
    @Environment(\.dismiss) private var dismiss
    @State private var pendingWeights: [String: PendingWeight] = [:]
       
    init(initialDate: Date, viewModel: WeightEntryViewModel = WeightEntryViewModel()) {
            self._viewModel = StateObject(wrappedValue: viewModel)
            self._currentDate = State(initialValue: initialDate.startOfDay)
        }
    
    private func savePendingWeights() {
            for (dateSid, weights) in pendingWeights {
                let amValue = Double(weights.amWeight)
                let pmValue = Double(weights.pmWeight)
                if amValue != nil || pmValue != nil {
                    guard let date = Date(datestampSid: dateSid) else {
                        print("Invalid dateSid: \(dateSid), skipping save")
                        continue
                    }
                    viewModel.saveWeight(
                        for: date,
                        amWeight: amValue,
                        pmWeight: pmValue,
                        amTime: weights.amTime,
                        pmTime: weights.pmTime
                    )
                    print("Saved pending weights for \(dateSid)")
                }
            }
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
                savePendingWeights()
                if newDate > Date().startOfDay {
                    currentDate = Date().startOfDay
                }
                print("WeightEntryView changed to date: \(newDate.datestampSid)")
            }
            .navigationTitle("Weight")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                      Button("Back") {
                          savePendingWeights()
                         dismiss()
                                    }
                                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        savePendingWeights()
                        currentDate = Date().startOfDay }) {
                        Text("Today")
                    }
                }
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
            // Banner-like date display
            Text("Date: \(date.datestampSid)")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.brandGreen) //TBDz need to make green
                .border(Color.gray, width: 1)
                .padding(.horizontal)
            //TBDz this form and page needs localization
            Form {
                Section(header: Text("Morning Weight (AM)")) {
                    TextField("Weight (\(unitType == .metric ? "kg" : "lbs"))", text: $amWeight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    onSubmit {
                        if let value = Double(amWeight), value >= 0 {
                            amWeight = String(format: "%.1f", value)
                         } else {
                             amWeight = ""
                                  }
                            }
                    DatePicker("Time", selection: $amTime, displayedComponents: .hourAndMinute)
                        .onChange(of: amTime) { _ in saveWeights() }
                }
                Section(header: Text("Evening Weight (PM)")) {
                    TextField("Weight (\(unitType == .metric ? "kg" : "lbs"))", text: $pmWeight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                             if let value = Double(pmWeight), value >= 0 {
                                      pmWeight = String(format: "%.1f", value)
                              } else {
                                      pmWeight = ""
                                   }
                          }
                    DatePicker("Time", selection: $pmTime, displayedComponents: .hourAndMinute)
                        .onChange(of: pmTime) { _ in saveWeights() }
                }
            }
        }
        .onAppear {
            loadWeights()
            unitType = .fromUserDefaults()
            print("WeightEntryPage appeared for date: \(date.datestampSid), AM: \(amWeight), PM: \(pmWeight)")
                   
        }
        .onChange(of: amWeight) {
                    updatePendingWeights()
                }
                .onChange(of: pmWeight) {
                    updatePendingWeights()
                }
                .onChange(of: amTime) {
                    updatePendingWeights()
                }
                .onChange(of: pmTime) {
                    updatePendingWeights()
                }
                .onChange(of: unitType) {
                    loadWeights()
                }
        
    }
    
    private func loadWeights() {
        let tracker = viewModel.tracker(for: date)
        let unitType = UnitType.fromUserDefaults()
        
        amWeight = tracker.weightAM.dataweight_kg > 0 ? (unitType == .metric ? tracker.weightAM.kgStr : tracker.weightAM.lbsStr) : ""
        pmWeight = tracker.weightPM.dataweight_kg > 0 ? (unitType == .metric ? tracker.weightPM.kgStr : tracker.weightPM.lbsStr) : ""
        
        amTime = tracker.weightAM.datetime ?? Date()
        pmTime = tracker.weightPM.datetime ?? Date()
    }
    
   // Converts user input (amWeight and pmWeight strings) to Double and calls viewModel.saveWeight to persist the data.
    private func saveWeights() {
        let amValue = Double(amWeight)
        let pmValue = Double(pmWeight)
        print("Saving AM: \(String(describing: amValue)), PM: \(String(describing: pmValue)), Unit: \(unitType.rawValue)")
        viewModel.saveWeight(for: date, amWeight: amValue, pmWeight: pmValue, amTime: amTime, pmTime: pmTime)
        print("Saved AM/PM")
    }
    
    private func updatePendingWeights() {
            pendingWeights[date.datestampSid] = PendingWeight(
                amWeight: amWeight,
                pmWeight: pmWeight,
                amTime: amTime,
                pmTime: pmTime
            )
            print("Updated pending weights for \(date.datestampSid): AM \(amWeight), PM \(pmWeight)")
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
