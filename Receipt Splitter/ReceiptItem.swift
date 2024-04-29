ReceiptItem.swift://
//  ReceiptItem.swift
//  Receipt Splitter
//
//  Created by Brian Liu on 12/29/23.
//

import Foundation

struct ReceiptItem: Identifiable {
    let id = UUID()
    var name: String
    var price: Double
    var assignedTo: String? // Optional name of the person this item is assigned to
}
and userSelectionView.swift://
