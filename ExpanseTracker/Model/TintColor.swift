//
//  TintColor.swift
//  ExpanseTracker
//
//  Created by Ricky Primayuda Putra on 16/11/24.
//

import SwiftUI

struct TintColor: Identifiable {
    let id: UUID = UUID()
    var color: String
    var value: Color
}

var tints: [TintColor] = [
    .init(color: "Red", value: .red),
    .init(color: "Orange", value: .orange),
    .init(color: "Blue", value: .blue),
    .init(color: "Purple", value: .purple),
    .init(color: "Pink", value: .pink),
    .init(color: "Brown", value: .brown)
]
