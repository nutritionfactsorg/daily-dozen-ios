//
//  WeightEntryView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI
//TBDz this page needs localization
struct WeightEntryView: View {
    @StateObject private var viewModel = WeightEntryViewModel()
    @State private var currentDate: Date = Date().startOfDay
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentDate) {
                ForEach(0...30, id: \.self) { offset in
                    let date = Date().startOfDay.adding(days: -offset)
                    WeightEntryPage(date: date, viewModel: viewModel)
                        .tag(date)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: currentDate) { newDate in
                if newDate > Date().startOfDay {
                    currentDate = Date().startOfDay
                }
            }
            .navigationTitle("Weight")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { currentDate = Date().startOfDay }) {
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
                        .onChange(of: amWeight) { _ in saveWeights() }
                    DatePicker("Time", selection: $amTime, displayedComponents: .hourAndMinute)
                        .onChange(of: amTime) { _ in saveWeights() }
                }
                Section(header: Text("Evening Weight (PM)")) {
                    TextField("Weight (\(unitType == .metric ? "kg" : "lbs"))", text: $pmWeight)
                        .keyboardType(.decimalPad)
                        .onChange(of: pmWeight) { _ in saveWeights() }
                    DatePicker("Time", selection: $pmTime, displayedComponents: .hourAndMinute)
                        .onChange(of: pmTime) { _ in saveWeights() }
                }
            }
        }
        .onAppear {
            loadWeights()
            unitType = .fromUserDefaults()
        }
        .onChange(of: unitType) { _ in loadWeights() }
    }
    
    private func loadWeights() {
        let tracker = viewModel.tracker(for: date)
        let unitType = UnitType.fromUserDefaults()
        
        amWeight = tracker.weightAM.dataweight_kg > 0 ? (unitType == .metric ? tracker.weightAM.kgStr : tracker.weightAM.lbsStr) : ""
        pmWeight = tracker.weightPM.dataweight_kg > 0 ? (unitType == .metric ? tracker.weightPM.kgStr : tracker.weightPM.lbsStr) : ""
        
        amTime = tracker.weightAM.datetime ?? Date()
        pmTime = tracker.weightPM.datetime ?? Date()
    }
    
    private func saveWeights() {
        let amValue = Double(amWeight)
        let pmValue = Double(pmWeight)
        print("Saving AM: \(String(describing: amValue)), PM: \(String(describing: pmValue)), Unit: \(unitType.rawValue)")
        viewModel.saveWeight(for: date, amWeight: amValue, pmWeight: pmValue, amTime: amTime, pmTime: pmTime)
    }
}
// Preview
struct WeightEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WeightEntryView()
        }
    }
}
