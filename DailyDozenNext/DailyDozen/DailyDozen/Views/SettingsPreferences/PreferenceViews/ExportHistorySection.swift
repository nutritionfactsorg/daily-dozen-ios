//
//  ExportHistorySection.swift
//  DailyDozen
//
//  Created by mc on 2/10/25.
//

import SwiftUI

struct ExportHistorySection: View {
    
    func exportHistory() {
        print("need to implement")
        //NYIz
    }
    var body: some View {
        VStack {
            Text("history_data_title")
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
                //.padding(10)
            Button("history_data_export_btn", action: exportHistory)
                .foregroundStyle(.brandGreen)
        }
    }
}

#Preview {
    ExportHistorySection()
}
