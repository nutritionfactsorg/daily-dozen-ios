//
//  ExportHistorySection.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct ExportHistorySection: View {
    @State private var isExporting = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("history_data_title")
                .textCase(.uppercase)
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
            
            if isExporting {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("history_data_export_btn") //TBDz, should say "Exporting", but this will work.
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                Button("history_data_export_btn") {
                    exportCSV()
                }
                .foregroundStyle(.nfGreenBrand)
            }
        }
    }
    
    private func exportCSV() {
            isExporting = true
            
            Task { 
                let csvString = await SQLiteConnector.shared.generateCSVContent(marker: "ExportCSV")
                let data = csvString.data(using: .utf8) ?? Data()
                
                let filename = "ExportCSV-\(Date().formatted(.iso8601.year().month().day()))-\(Int(Date().timeIntervalSince1970)).csv"
                let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = docsURL.appendingPathComponent(filename)
                
                try? data.write(to: fileURL, options: .atomic)
                
                await MainActor.run {
                    let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                    
                    if let windowScene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
                       let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                        
                        activityVC.popoverPresentationController?.sourceView = rootVC.view
                        activityVC.popoverPresentationController?.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                        activityVC.popoverPresentationController?.permittedArrowDirections = []
                        
                        // SPINNER FIX: Simple, explicit params (no @MainActor bug)
                        activityVC.completionWithItemsHandler = { _, _, _, _ in
                            isExporting = false
                        }
                        
                        rootVC.present(activityVC, animated: true)
                    } else {
                        isExporting = false
                    }
                }
            }
        }
}
