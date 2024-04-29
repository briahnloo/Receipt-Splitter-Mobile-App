//  UserSelectionView.swift
//  Receipt Splitter
//
//  Created by Brian Liu on 12/29/23.
//
import SwiftUI

struct UserSelectionView: View {
    @Binding var items: [ReceiptItem]
    @State private var selectedItems: Set<UUID> = []

    var body: some View {
        List(items) { item in
            HStack {
                Text(item.name)
                Spacer()
                Image(systemName: selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                    .onTapGesture {
                        if selectedItems.contains(item.id) {
                            selectedItems.remove(item.id)
                        } else {
                            selectedItems.insert(item.id)
                        }
                    }
            }
        }
        .navigationBarTitle("Select Your Items", displayMode: .inline)
    }
}
