//
//  CheckboxView.swift
//  DailyDozen
//
//  Created by mc on 3/11/25.
//

import SwiftUI

struct CheckboxView: View {
    // @Binding var isChecked: Bool
    @State var isChecked: Bool
    
    var body: some View {
        Button(action: {
            isChecked.toggle()
        }, label: {
            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 20, height: 20) //
                .foregroundColor(isChecked ? .brandGreen : .grayLight)
                .fontWeight(.heavy)
        })
    }
}

struct CheckboxView2: View {
    // @Binding var isChecked: Bool
    let isChecked: Bool
    let onTap: () -> Void
    
    var body: some View {
       
            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 20, height: 20) //
                .foregroundColor(isChecked ? .brandGreen : .grayLight)
                .fontWeight(.heavy)
                .onTapGesture {
                    onTap()
                    logit.debug("OnTapGesture")
                }
        
    }
}

struct CheckboxView3: View {
    let isChecked: Bool
    //let onTap: () -> Void
  //  let onChange: (Int) -> Void
    var body: some View {
       
            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 20, height: 20) //
                .foregroundColor(isChecked ? .brandGreen : .grayLight)
                .fontWeight(.heavy)
    }
}

#Preview {
    //let isChecked = true
    HStack(spacing: 20) {
            CheckboxView2(
                isChecked: false,
                onTap: { print("Tapped unchecked box") }
            )
            CheckboxView3(
                isChecked: true)
               // onTap: { print("Tapped checked box") }
        }
        .padding()
    }
