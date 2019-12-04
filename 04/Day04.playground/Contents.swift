enum ValidationRule {
    case adjacentDigits
    case adjacentDigitsNotRepeating
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

class AdjacentNotRepeatingValidator: Validator {
    func isValid(password: [Int]) -> Bool {
        var hasDouble: Bool = false
        for i in password.indices {
            guard i > 0 else {
                continue
            }
            
            if password[i] == password[i - 1] {
                // we have a match, is either side bad?
                if i > 1, password[i] == password[i - 2] {
                    // its a 3! the digit before is the same as the pair
                    continue
                }
                if i < (password.count - 1), password[i] == password[i + 1] {
                    // its a 3! the digit after is the same as the pair
                    continue
                }
                
                hasDouble = true
            }
        }
        
        return hasDouble
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
        if validationRules.contains(.adjacentDigitsNotRepeating) {
            validators.append(AdjacentNotRepeatingValidator())
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


// Part Two
// No more than 2 repeating (one set of 2 is ok, if there is another set that is more matching)
let passwordFinder = PasswordFinder(numDigits: 6, min: 128392, max: 643281, validationRules: [.doesntDecrease, .adjacentDigitsNotRepeating])
let y = passwordFinder.calculatePasswords()
print("Part Two Answer \(y.count)")
