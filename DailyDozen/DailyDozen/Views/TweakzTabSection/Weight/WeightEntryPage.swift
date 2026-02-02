//
//  WeightEntryPage.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI
//import UIKit  // For resignFirstResponder for keyboard dismissal across iOS 17/18/26

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
    
    enum FocusedField {
            case amWeight
            case pmWeight
        }
        
    @FocusState private var focusedField: FocusedField?
    
    @State private var saveTask: Task<Void, Never>?
  
    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 600_000_000) // prevent saving every keystroke?
            await viewModel.updatePendingWeights(
                for: date,
                amWeight: amWeight,
                pmWeight: pmWeight,
                amTime: amTime,
                pmTime: pmTime
            )
        }
    }
    
    private func loadWeightData() {
        Task {
            let normalized = DateUtilities.gregorianCalendar.startOfDay(for: date)
            await viewModel.loadTracker(forDate: normalized)
            let data = await viewModel.loadWeights(for: date, unitType: unitType)
            await MainActor.run {
                amWeight = data.amWeight
                pmWeight = data.pmWeight
                amTime = data.amTime
                pmTime = data.pmTime
            }
        }
    }
      
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {  // Reduced from 40 for more compact feel on small screens
                AMWeightSection(
                    date: date,
                    amWeight: $amWeight,
                    amTime: $amTime,
                    showClearConfirmation: $showClearAMConfirmation,
                    focused: $focusedField,
                    unitType: unitType,
                    onSave: scheduleSave,
                )
                
                PMWeightSection(
                    date: date,
                    pmWeight: $pmWeight,
                    pmTime: $pmTime,
                    showClearConfirmation: $showClearPMConfirmation,
                    unitType: unitType,
                    onSave: scheduleSave,
                    focused: $focusedField
                )
                
                Color.clear.frame(height: 150)  // Extra draggable space at bottom
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .scrollDismissesKeyboard(.interactively)
     
        .onTapGesture {
                focusedField = nil  // Clean dismissal via pure SwiftUI
            }
        .onChange(of: focusedField) { oldValue, newValue in
            guard newValue == nil, let lostFocus = oldValue else { return }  // Editing ended
            
            if lostFocus == .amWeight {
                if !amWeight.isEmpty && amWeight.toWeightDouble() == nil {
                    amWeight = ""
                    scheduleSave()
                }
            } else if lostFocus == .pmWeight {
                if !pmWeight.isEmpty && pmWeight.toWeightDouble() == nil {  // Use pmWeight (parent state)
                    pmWeight = ""
                    scheduleSave()
                }
            }
        }

        .confirmationDialog("weight_entry_morning", isPresented: $showClearAMConfirmation, titleVisibility: .visible) {
            Button("weight_entry_clear", role: .destructive) {
                saveTask?.cancel()
                Task {
                    await viewModel.clearPendingWeight(for: date, weightType: .am)
                    await viewModel.deleteWeight(for: date, weightType: .am)
                    await MainActor.run { amWeight = "" }
                    await viewModel.updatePendingWeights(for: date, amWeight: "", pmWeight: pmWeight, amTime: amTime, pmTime: pmTime)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("\(date.formatted(date: .long, time: .omitted))?")
        }
        .confirmationDialog("weight_entry_evening", isPresented: $showClearPMConfirmation, titleVisibility: .visible) {
            Button("weight_entry_clear", role: .destructive) {
                saveTask?.cancel()
                Task {
                    await viewModel.clearPendingWeight(for: date, weightType: .pm)
                    await viewModel.deleteWeight(for: date, weightType: .pm)
                    await MainActor.run { pmWeight = "" }
                    await viewModel.updatePendingWeights(for: date, amWeight: amWeight, pmWeight: "", amTime: amTime, pmTime: pmTime)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("\(date.formatted(date: .long, time: .omitted))?")
        }
        .onAppear {
            loadWeightData()
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
        .onDisappear {
            Task {
                await viewModel.clearPendingWeight(for: date, weightType: .am)
                await viewModel.clearPendingWeight(for: date, weightType: .pm)
               
                await viewModel.updatePendingWeights(for: date, amWeight: amWeight, pmWeight: pmWeight, amTime: amTime, pmTime: pmTime)
                await viewModel.savePendingWeights()
            }
        }
    }
}

struct AMWeightSection: View {
    let date: Date
    @Binding var amWeight: String
    @Binding var amTime: Date
    @Binding var showClearConfirmation: Bool
    var focused: FocusState<WeightEntryPage.FocusedField?>.Binding
    let unitType: UnitType
    let onSave: () -> Void
    
    private var unitsPrompt: Text {
        Text("(") + (unitType == .metric ? Text("weight_entry_units_kg") : Text("weight_entry_units_lbs")) + Text(")")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {  // Compact spacing
            Text("weight_entry_morning")
               // .font(.title2.bold())
                .font(.headline.bold())
            
            TextField("", text: $amWeight, prompt: unitsPrompt)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .focused(focused, equals: .amWeight)
                .onChange(of: amWeight) { oldValue, newValue in
                    if newValue.isEmpty || newValue.toWeightDouble() != nil {
                        onSave()
                    } else {
                        amWeight = oldValue  // ← Explicitly revert invalid entry
                    }
                }
            
            DatePicker("weight_entry_time", selection: $amTime, in: date.userDisplayStartOfDay...date.userEndOfAM, displayedComponents: .hourAndMinute)
                .onChange(of: amTime) { _, _ in onSave() }
            let viewModel = SqlDailyTrackerViewModel.shared
            if !amWeight.isEmpty || viewModel.tracker(for: date).weightAM != nil {
                HStack {
                    Spacer()
                    Button("weight_entry_clear") { showClearConfirmation = true }
                        .buttonStyle(.borderless)
                        .tint(.nfRedFlamePea)
                    Spacer()
                }
            }
        }
    }
}

struct PMWeightSection: View {
    // Identical changes: spacing 16, no card background, same validation
    let date: Date
    @Binding var pmWeight: String
    @Binding var pmTime: Date
    @Binding var showClearConfirmation: Bool
    let unitType: UnitType
    let onSave: () -> Void
    var focused: FocusState<WeightEntryPage.FocusedField?>.Binding
    private var unitsPrompt: Text {
        Text("(") + (unitType == .metric ? Text("weight_entry_units_kg") : Text("weight_entry_units_lbs")) + Text(")")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("weight_entry_evening")
                .font(.headline.bold())
            
            TextField("", text: $pmWeight, prompt: unitsPrompt)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .focused(focused, equals: .pmWeight)
                .onChange(of: pmWeight) { oldValue, newValue in
                    if newValue.isEmpty {
                        onSave() // scheduleSave() when value is cleared "empty"
                    } else if newValue.toWeightDouble() != nil {
                        onSave() // scheduleSave() when value is updated
                    } else {
                        pmWeight = oldValue //  Explicitly revert invalid entry
                    }
                      
                }
            
            DatePicker("weight_entry_time", selection: $pmTime, in: date.userNoon...date.userEndOfDay, displayedComponents: .hourAndMinute)
                .onChange(of: pmTime) { _, _ in onSave() }  //if change time
            let viewModel = SqlDailyTrackerViewModel.shared
            if !pmWeight.isEmpty || viewModel.tracker(for: date).weightPM != nil {
                HStack {
                    Spacer()
                    Button("weight_entry_clear") { showClearConfirmation = true }
                        .buttonStyle(.borderless)
                        .tint(.nfRedFlamePea)
                    Spacer()
                }
            }
        }
    }
}
