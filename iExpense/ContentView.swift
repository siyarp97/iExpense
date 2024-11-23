//
//  ContentView.swift
//  iExpense
//
//  Created by Şiyar Palabıyık on 20.11.2024.
//

import SwiftUI
import Observation

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let type : String
    let name : String
    let amount : Double
}

@Observable
class Expenses{
    var items = [ExpenseItem](){
        
        didSet{
            if let encodedItem = try? JSONEncoder().encode(items){
                UserDefaults.standard.set(encodedItem, forKey: "Items")
            }
        }
    }
    
    init(){
        if let savedItems = UserDefaults.standard.data(forKey: "Items"){
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems){
                items = decodedItems
                return
            }
        }
        items = []
    }
}

struct ContentView: View {
    
    @State private var expenses = Expenses()
    @State private var showAddExpense = false
    
    var personal : [ExpenseItem] { expenses.items.filter{$0.type == "Personal"} }
    var business : [ExpenseItem] { expenses.items.filter{$0.type == "Business"} }
    
    var body: some View {
        NavigationStack{
            VStack{
                List{
                    sectionView()
                }
                VStack{
                    Spacer()
                    Text("Open To Work!")
                        .padding(.top)
                    Text("siyarp97@gmail.com")
                        .offset(y:5)
                }
                    .frame(width: 250, height: 50)
                    .background(.regularMaterial
                        .blendMode(.sourceAtop)
                        .shadow(.drop(radius: 20)))
            }
            .navigationTitle("iExpense")
            .toolbar{
                Button("Add", systemImage: "plus") {
                    showAddExpense = true
                    print(expenses.items)
                    print(personal)
                    print(business)
                }
            }.background(
                LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .scrollContentBackground(.hidden)
            .sheet(isPresented: $showAddExpense, content: {
                AddView(expenses: expenses)
            })
        }
    }
    
    func deleteItem(at offsets: IndexSet, for section : String) {
        let sectionArray = section == "Personal" ? personal : business
        
        for offSet in offsets{
            let item = sectionArray[offSet]
            expenses.items.removeAll{ $0.id == item.id }
        }
    }
    
    @ViewBuilder
    func decideColor(for amount : Double) -> some View{
        let format = Locale.current.currency?.identifier ?? "USD"
        
        if amount <= 10 {
            Text(amount, format: .currency(code: format))
                .foregroundStyle(.green)
        }
        else if amount > 10 && amount <= 100{
            Text(amount, format: .currency(code: format))
                .foregroundStyle(.yellow)
        }
        else {
            Text(amount, format: .currency(code: format))
                .foregroundStyle(.red)
        }
        
    }
    
    @ViewBuilder
    func rowView(_ item: ExpenseItem) -> some View{
        HStack{
            VStack{
                Text(item.name)
                    .font(.headline)
                Text(item.type)
            }
            Spacer()
            decideColor(for: item.amount)
        }
    }
    
    @ViewBuilder
    func sectionView() -> some View{
        Section(personal.isEmpty ? "" : "Personal"){
            ForEach(personal){ rowView($0) }
                .onDelete(perform: { indexSet in
                    deleteItem(at: indexSet, for: "Personal")
                })
            }
        Section(business.isEmpty ? "" : "Business"){
            ForEach(business){ rowView($0) }
                .onDelete(perform: { indexSet in
                    deleteItem(at: indexSet, for: "Business")
                })
        }
    }
    
}


#Preview {
    ContentView()
}
