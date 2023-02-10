import Foundation

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
