//
//  ScratchView.swift
//  DailyDozen
//
//  Created by mc on 2/17/25.
//

import SwiftUI

struct ScratchView: View {
    let dictionary: [String: Int] = ["apple": 5, "banana": 3, "cherry": 8, "date": 1]
    var body: some View {
//        VStack {
//                    // Convert dictionary to sorted array based on keys
//                    let sortedArray = dictionary.sorted { $0.key < $1.key }
//                    
//                    ForEach(sortedArray, id: \.key) { key, value in
//                        Text("\(key): \(value)")
//                    }
//                }
        VStack {
            let sortedArray2 = DataCountAttributes.shared.dict.sorted { $0.key.rawValue < $1.key.rawValue }
            
            ForEach(sortedArray2, id: \.key) { key, value in
                HStack {
                    Text(value.headingDisplay)
                    Text("\(key)")
                }
               
            }
            
        }
//        VStack {
////                    List {
////                        ForEach(DataCountAttributes.shared.dict.keys, id: \.self) {name in
////                            Text(name.headingDisplay)
////                        }
////                    } //List
//            ForEach(Array(DataCountAttributes.shared.dict), id: \.key) {
//                _, value in
//                Text(value.headingDisplay)
//            }
//        } //VStack
//        Text("****")
//        ForEach(Array(DataCountAttributes.shared.dict), id: \.key) {
//            _, value in
//          //  if value.id < 100 {
//                Text(value.headingDisplay)
//           // }
//        }
//        Text("****")
    }
}

#Preview {
    ScratchView()
}
