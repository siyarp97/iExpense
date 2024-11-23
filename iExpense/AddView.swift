//
//  AddView.swift
//  iExpense
//
//  Created by Şiyar Palabıyık on 22.11.2024.
//

import SwiftUI

struct AddView: View {
    @Environment (\.dismiss) var dismiss
    
    var expenses : Expenses
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = 0.0
    
    let types = ["Business", "Personal"]
    
    var body: some View {
        NavigationStack{
            Form{
                TextField("Name", text: $name)
                
                Picker("Type", selection: $type) {
                    ForEach(types, id: \.self){ Text($0) }
                }
                
                TextField("Amount", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
            }
                        .navigationTitle("Add Expense")
            .toolbar{
                Button("Save"){
                    let expense = ExpenseItem(type: type, name: name, amount: amount)
                    expenses.items.append(expense)
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    AddView(expenses: Expenses())
}
