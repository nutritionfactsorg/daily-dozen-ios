//
//  ImportSQLiteView.swift
//  DailyDozen
//
//  Copyright © 2025-2026 NutritionFacts.org. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportCSVtoSQLiteView: View {
    @State private var showingCSVImporter = false
    @State private var importStatus: String = ""

    var body: some View {
        VStack(spacing: 20) {                               // ← added container
            Button("Import CSV → Rebuild DB (debug)") {
                showingCSVImporter = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)

            if !importStatus.isEmpty {
                Text(importStatus)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            Spacer()                                        // optional: push to top
        }
        .padding()
        .sheet(isPresented: $showingCSVImporter) {         // ← NOW correctly attached
            CSVFilePicker { csvURL in
                Task { @MainActor in
                    do {
                        try await SQLiteConnector.shared.performCSVImportAndRebuild(from: csvURL)
                        importStatus = "CSV imported & DB rebuilt"
                    } catch {
                        importStatus = "Failed: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

struct CSVFilePicker: UIViewControllerRepresentable {
    let onPick: (URL) -> Void
    
    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.commaSeparatedText, .utf8PlainText, .plainText],
            asCopy: true                 // CSV is text → safe & fast copy
        )
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        init(onPick: @escaping (URL) -> Void) { self.onPick = onPick }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                onPick(url)               // sandboxed copy of the CSV
            }
        }
    }
}
