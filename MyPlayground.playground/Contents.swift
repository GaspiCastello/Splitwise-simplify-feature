import Foundation
import PlaygroundSupport

public let ok = "🤙🏽"
public let badBalance = "🤯"

public typealias Percentage = Double
public typealias Amount = Double
public typealias Debt = [Person: Amount]

public class Person {
    let name: String
    let id =  UUID().uuidString
    var groups = [Group]()
    lazy var balance: Debt = { getBalance() }()
    var reducedBalance: Double { balance.reduce(0) { $0 + $1.value } }
    var simplifiedBalance = Debt()
    var isPayer: Bool { reducedBalance > 0 }
    
    public init(name: String) {
        self.name = name
    }
    
    private func getBalance() -> Debt {
        //debit
        var summary = Debt()
        let expenses = Expenses.shared.list
        let debits = expenses.filter { exp in
            exp.paidBy != self && (exp.shareWith[self] != nil)
        }
        debits.forEach { exp in
            let total = exp.amount
            let percentage = exp.shareWith[self]!
            summary[exp.paidBy] = (summary[exp.paidBy] ?? 0) + total*percentage
        }
        
        //credit
        let credits = expenses.filter { exp in
            exp.paidBy == self
        }
        credits.forEach { exp in
            let total = exp.amount
            exp.shareWith.forEach { sharing in
                let (person, percentage) = sharing
                var amount = total*percentage
                if person == self { return }
                summary[person] = (summary[person] ?? 0) - amount
            }
        }
        return summary
    }
    
}

extension Person: Hashable {
    
    public static func == (lhs: Person, rhs: Person) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


public let Tin = Person(name: "Tin")
public let Bian = Person(name: "Bian")
public let Gaspi = Person(name: "Gaspi")
public let Pablo = Person(name: "Pablo")
public let Eli = Person(name: "Eli")
public let Terra = Person(name: "Terra")

public class Group {
    let name: String
    let users: [Person]
    var receivers: [Person] { users.filter { !$0.isPayer } }
    var payers: [Person] { users.filter { $0.isPayer } }
    
    init(name: String, users: [Person]) {
        self.name = name
        self.users = users
    }
    
    func getSimplifiedBalance() {
        
        var receiversSorted = receivers.sorted { $0.reducedBalance < $1.reducedBalance }
        var payersSorted = payers.sorted { $0.reducedBalance > $1.reducedBalance }
        
        (users.reduce(0, { $0 + $1.reducedBalance }) > -0.001 && users.reduce(0, { $0 + $1.reducedBalance }) < 0.001) ? print(ok) : print(badBalance)
        //buscar iguales y combinaciones de dos a uno
        
        //empezar a reducir desde el mas pagador
        guard !payersSorted.isEmpty && !receiversSorted.isEmpty else { return }
        payersSorted.forEach { payer in
            var toRemove = [Person]()
            let total = receiversSorted.count
            
            for idx in 0..<total {
                let receiver = receiversSorted[idx]
                let currentReceiverAmount = receiver.reducedBalance - receiver.simplifiedBalance.reduce(0, { $0 + $1.value })
                let currentPayerAmount = payer.reducedBalance - payer.simplifiedBalance.reduce(0, { $0 + $1.value })
                let payerCancelled = (currentPayerAmount + currentReceiverAmount) < 0
                
                let amount = payerCancelled ? currentPayerAmount : (0-currentReceiverAmount)
                receiver.simplifiedBalance[payer] = (0-amount)
                payer.simplifiedBalance[receiver] = amount
                if payerCancelled {
                    break
                } else {
                    toRemove.append(receiver)
                }
            }
            receiversSorted.removeAll { toRemove.contains($0) }
        }
    }
}


public let newGroup = Group(name: "Bari", users: [Bian,Gaspi,Tin,Pablo,Eli,Terra])

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

newGroup.getSimplifiedBalance()

newGroup.users.sorted(by: { $0.reducedBalance > $1.reducedBalance}).forEach { person in
    print("\n\n Resumen de \(person.name), $\(person.reducedBalance)")
    person.simplifiedBalance.forEach { debt in
        let str = debt.value > 0 ? "Pagar a " : "Cobrar a "
        print("\n", str, debt.key.name," $", debt.value) }
}
