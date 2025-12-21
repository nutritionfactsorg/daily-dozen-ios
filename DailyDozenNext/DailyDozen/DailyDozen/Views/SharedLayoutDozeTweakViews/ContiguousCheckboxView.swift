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
    @Binding var x: Int    // Number of checked boxes 
    let direction: Direction
    let onChange: (Int) -> Void // Callback for count changes
    let isDisabled: Bool
    let onTap: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 10) {
            // Generate checkboxes based on direction
            if direction == .leftToRight {
                ForEach(0..<n, id: \.self) { index in
                    Image(systemName: index < x ? "checkmark.square.fill" : "square")
                        .resizable()
                        .frame(width: 20, height: 20) //
                        .foregroundColor(index < x ? .nfGreenBrand : .nfGrayLight)
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
                        .foregroundColor(index < x ? .nfGreenBrand : .nfGrayLight)
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
            
        }
    }
}

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
