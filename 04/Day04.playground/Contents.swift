enum ValidationRule {
    case adjacentDigits
    case doesntDecrease
}

protocol Validator: class {
    func isValid(password: [Int]) -> Bool
}

class AdjacentValidator: Validator {
    func isValid(password: [Int]) -> Bool {
        for i in password.indices {
            guard i > 0 else {
                continue
            }
            
            if password[i] == password[i - 1] {
                return true
            }
        }
        
        return false
    }
}

class DecreasingValidator: Validator {
    func isValid(password: [Int]) -> Bool {
        for i in password.indices {
            guard i > 0 else {
                continue
            }
            
            guard password[i] >= password[i - 1] else {
                return false
            }
        }
        return true
    }
}

class PasswordFinder {
    let numDigits: Int
    let minNum: Int
    let maxNum: Int
    
    var validators: [Validator] = []
    
    init(numDigits: Int, min: Int, max: Int, validationRules: [ValidationRule]) {
        self.numDigits = numDigits
        self.minNum = min
        self.maxNum = max
        
        if validationRules.contains(.adjacentDigits) {
            validators.append(AdjacentValidator())
        }
        if validationRules.contains(.doesntDecrease) {
            validators.append(DecreasingValidator())
        }
    }
    
    func calculatePasswords() -> [String] {
        var passwords = [String]()
        
        for i in minNum...maxNum {
            let password = String(i)
            guard password.count == numDigits else {
                continue
            }
            let components = password.map({ return Int(String($0))! })
            
            if isValid(components) {
                passwords.append(password)
            }
        }
        
        return passwords
    }
    
    private func isValid(_ password: [Int]) -> Bool {
        for validator in validators {
            guard validator.isValid(password: password) else {
                return false
            }
        }
        
        return true
    }
}

// Part One
// rules
// must have matching adjacent digits
// numbers left - right must never decrease (0 is ok)
let passwordFinder = PasswordFinder(numDigits: 6, min: 128392, max: 643281, validationRules: [.adjacentDigits,.doesntDecrease])
let x = passwordFinder.calculatePasswords()
print("Part One Answer\(x.count)")


