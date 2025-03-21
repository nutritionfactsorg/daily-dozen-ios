//
//  CongiguousCheckboxView.swift
//  DailyDozen
//
//  Created by mc on 3/19/25.
//

import SwiftUI

enum Direction {
    case leftToRight
    case rightToLeft
}

struct ContiguousCheckboxView: View {
    let n: Int          // Total number of checkboxes
    @State private var x: Int    // Number of checked boxes //Might need to Change to @Binding so parent can access and modify it, depending on when save to database occurs.
    
    init(n: Int, x: Int, direction: Direction) {
        self.n = max(1, n)  // Ensure at least 1 checkbox
        self._x = State(initialValue: min(x, n))  // Ensure x doesn't exceed n
        self.direction = direction
    }
    
    let direction: Direction
    var body: some View {
        HStack(spacing: 10) {
            // Generate checkboxes based on direction
            if direction == .leftToRight {
                ForEach(0..<n, id: \.self) { index in
                    CheckboxView2(
                        isChecked: index < x,
                        onTap: { handleTap(at: index) }
                    )
                }
            } else {
                ForEach((0..<n).reversed(), id: \.self) { index in
                    
                    CheckboxView2(
                        // Check it if its position is less than number checked
                        isChecked: index < x,
                        onTap: { handleTap(at: index) }
                    )
                }
            }
        }
        .onDisappear {
        // Save to database when this view goes away
      //  saveToDatabase(x: x)
            //may also need to do it on change of scene phase
//
    }
    }
    
    // This figures out what to do when someone taps a checkbox
    private func handleTap(at index: Int) {
        let adjustedIndex = direction == .leftToRight ? index : (n - 1 - index)
        
        // If tapping an unchecked box
        if adjustedIndex >= x {
            x = adjustedIndex + 1
        }
        // If tapping a checked box
        else {
            // Uncheck this box and everything after it
            x = adjustedIndex
        }
        //saveToDatabase here is want to save after each tap. might be overkill and may want to just save when View Disappears
    }
}

#Preview {
    ContiguousCheckboxView(n: 3, x: 2, direction: .leftToRight)
}
