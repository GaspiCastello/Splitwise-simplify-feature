import Foundation

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

