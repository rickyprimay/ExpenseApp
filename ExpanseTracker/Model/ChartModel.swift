//
//  ChartModel.swift
//  ExpanseTracker
//
//  Created by Ricky Primayuda Putra on 17/11/24.
//

import SwiftUI

struct ChartGroup: Identifiable {
    let id: UUID = UUID()
    var date: Date
    var categories: [ChartCategory]
    var totalIncome: Double
    var totalExpense: Double
}

struct ChartCategory: Identifiable {
    let id: UUID = UUID()
    var totalValue: Double
    var category: Category
}
