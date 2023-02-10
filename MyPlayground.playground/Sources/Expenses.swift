import Foundation

public struct Expense {
    let id = UUID().uuidString
    let amount: Double
    let paidBy: Person
    let shareWith: [Person: Percentage]
}

public final class Expenses {
    public static let shared = Expenses()
    var list = [Expense]()
    
    func addExpense(_ expense: Expense) {
        list.append(expense)
    }
    
    func addExpenses(_ expenses: [Expense]) {
        expenses.forEach { expense in
            list.append(expense)
        }
    }
    
    func removeExpense(_ id: String) {
        list.removeAll { $0.id == id }
    }
    
    func editExpenses(current id: String, to newExpense: Expense) {
        list.removeAll { $0.id == id }
        list.append(newExpense)
    }
}

Expenses.shared.addExpenses([
    Expense(amount: 25, paidBy: Gaspi, shareWith: [Bian: 0.4, Gaspi: 0.6]),
    Expense(amount: 10, paidBy: Tin, shareWith: [Bian: 0.1, Gaspi: 0.9]),
    Expense(amount: 66, paidBy: Bian, shareWith: [Bian: 0.5, Tin: 0.5]),
    Expense(amount: 20, paidBy: Pablo, shareWith: [Bian: 0.5, Terra: 0.5]),
    Expense(amount: 12, paidBy: Pablo, shareWith: [Bian: 2/3, Tin: 1/6, Gaspi: 1/6]),
    Expense(amount: 6, paidBy: Terra, shareWith: [Bian: 1/12, Tin: 3/12, Gaspi: 1/6, Pablo: 1/6, Eli: 1/6, Terra: 1/6]),
    Expense(amount: 6, paidBy: Bian, shareWith: [Bian: 0.5, Gaspi: 0.5]),
    Expense(amount: 26, paidBy: Pablo, shareWith: [Eli: 0.5, Pablo: 0.5]),
    Expense(amount: 26, paidBy: Bian, shareWith: [Bian: 0.5, Pablo: 0.5]),
    Expense(amount: 90, paidBy: Gaspi, shareWith: [Eli: 2/3, Tin: 1/6, Gaspi: 1/6])
])
