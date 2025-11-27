//
//  CongiguousCheckboxView.swift
//  DailyDozen
//
//  Copyright © 2025 Nutritionfacts.org. All rights reserved.
//

import SwiftUI

enum Direction {
    case leftToRight
    case rightToLeft
}

struct ContiguousCheckboxView: View {
    let n: Int          // Total number of checkboxes
    @Binding var x: Int    // Number of checked boxes //Might need to Change to @Binding so parent can access and modify it, depending on when save to database occurs.
    let direction: Direction
    let onChange: (Int) -> Void // Callback for count changes
    let isDisabled: Bool
    let onTap: (() -> Void)?
    
    //    init(n: Int, x: Int, direction: Direction) {
    //        self.n = max(1, n)  // Ensure at least 1 checkbox
    //        self._x = State(initialValue: min(x, n))  // Ensure x doesn't exceed n
    //        self.direction = direction
    //    }
    
    var body: some View {
        HStack(spacing: 10) {
            // Generate checkboxes based on direction
            if direction == .leftToRight {
                ForEach(0..<n, id: \.self) { index in
                    Image(systemName: index < x ? "checkmark.square.fill" : "square")
                        .resizable()
                        .frame(width: 20, height: 20) //
                        .foregroundColor(index < x ? .brandGreen : .grayLight)
                        .fontWeight(.heavy)
                        .onTapGesture {
                            if isDisabled {
                                onTap?()
                            } else {
                                let newX = index < x ? index : index + 1
                                x = newX
                                onChange(newX)
                            }
                        }
                }
            } else {
                ForEach((0..<n).reversed(), id: \.self) { index in
                    Image(systemName: index < x ? "checkmark.square.fill" : "square")
                        .resizable()
                        .frame(width: 20, height: 20) //
                        .foregroundColor(index < x ? .brandGreen : .grayLight)
                        .fontWeight(.heavy)
                        .onTapGesture {
                            if isDisabled {
                                onTap?()
                            } else {
                                let newX = index < x ? index : index + 1
                                x = newX
                                onChange(newX)
                            }
                        }
                }
                
            }
        }
        .onAppear {
            // print("ContiguousCheckboxView: n = \(n), x = \(x)")
        }
        .onDisappear {
            // Save to database when this view goes away
            //  saveToDatabase(x: x)
            //may also need to do it on change of scene phase
            //ModData(date: dateBeforeDays(-1))
            //
        }
    }
}
    
    // This figures out what to do when someone taps a checkbox
//    private func handleTap(at index: Int) {
//        let adjustedIndex = direction == .leftToRight ? index : (n - 1 - index)
//        
//        // If tapping an unchecked box
//        if adjustedIndex >= x {
//            x = adjustedIndex + 1
//        }
//        // If tapping a checked box
//        else {
//            // Uncheck this box and everything after it
//            x = adjustedIndex
//        }
//        //saveToDatabase here is want to save after each tap. might be overkill and may want to just save when View Disappears
//    }
//}

//#Preview {
//    ContiguousCheckboxView(n: 3, x: 2, direction: .leftToRight, onChange: (1))
//}
#Preview {
    struct PreviewWrapper: View {
        @State private var count = 2
        
        var body: some View {
            ContiguousCheckboxView(
                n: 3,
                x: $count,
                direction: .leftToRight,
                onChange: { newCount in count = newCount },
                isDisabled: false,
                onTap: { print("Tapped") }
            )
        }
    }
    return PreviewWrapper()
}
