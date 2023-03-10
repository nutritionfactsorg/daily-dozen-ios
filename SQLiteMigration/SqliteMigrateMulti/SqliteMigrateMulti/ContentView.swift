//
//  ContentView.swift
//  SqliteMigrateMulti
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button("Clear DB", action: SqliteConnector.run.clearDb)
            Button("Create Data", action: SqliteConnector.run.createData)
            Button("Export Data", action: SqliteConnector.run.exportData)
            Button("Import Data", action: SqliteConnector.run.importData)
            Button("Timing Test", action: SqliteConnector.run.timingTest)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
