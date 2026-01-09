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
        
        init(layoutDirection: LayoutDirection) {
            switch layoutDirection {
            case .leftToRight: self = .leftToRight
            case .rightToLeft: self = .rightToLeft
            @unknown default:
                self = .leftToRight
            }
        }
    
}

struct ContiguousCheckboxView: View {
    let n: Int          // Total number of checkboxes
    @Binding var x: Int    // Number of checked boxes
    
    let onChange: (Int) -> Void // Callback for count changes
    let isDisabled: Bool
    let onTap: (() -> Void)?
    // Read layout direction from environment
    @Environment(\.layoutDirection) private var layoutDirection
    private var direction: Direction {
        Direction(layoutDirection: layoutDirection)
    }
    
    var body: some View {
        HStack(spacing: 10) {
            // Generate checkboxes based on direction
            let indices = direction == .leftToRight ? Array(0..<n) : Array(0..<n).reversed()
            
            ForEach(indices, id: \.self) { index in
                Button {
                    if isDisabled {
                        onTap?()
                    } else {
                        let newX = index < x ? index : index + 1
                        x = newX
                        onChange(newX)
                    }
                } label: {
                    Image(systemName: index < x ? "checkmark.square.fill" : "square")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(index < x ? .nfGreenBrand : .nfGrayLight)
                        .fontWeight(.heavy)
                        .contentShape(Rectangle())
                    
                }
                //.buttonStyle(PlainButtonStyle())
                .buttonStyle(.borderless)
                
            }
            
        }
    }
}
        
        #Preview {
            VStack(spacing: 40) {
                // LTR preview
                VStack(alignment: .leading) {
                    Text("Left-to-Right (English)")
                        .font(.headline)
                    ContiguousCheckboxView(
                        n: 7,
                        x: .constant(4),
                        onChange: { newValue in print("New value:", newValue) },
                        isDisabled: false,
                        onTap: nil
                    )
                    .environment(\.layoutDirection, .leftToRight)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                
                // RTL preview
                VStack(alignment: .trailing) {
                    Text("Right-to-Left (Arabic / Hebrew)")
                        .font(.headline)
                    ContiguousCheckboxView(
                        n: 7,
                        x: .constant(4),
                        onChange: { newValue in print("New value:", newValue) },
                        isDisabled: false,
                        onTap: nil
                    )
                    .environment(\.layoutDirection, .rightToLeft)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                
                // Real-world simulation: force Arabic locale
                VStack(alignment: .trailing) {
                    Text("Arabic locale simulation")
                        .font(.headline)
                    ContiguousCheckboxView(
                        n: 6,
                        x: .constant(3),
                        onChange: { _ in },
                        isDisabled: false,
                        onTap: nil
                    )
                    .environment(\.locale, .init(identifier: "ar"))
                    // layoutDirection will automatically become .rightToLeft
                }
                .padding()
                .background(Color.gray.opacity(0.1))
            }
            .padding()
        }
 
