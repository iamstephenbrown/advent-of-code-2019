enum Opcode: Int {
    case add = 1
    case multiply = 2
    case exit = 99
}

enum IntcodeError: Error {
    case couldntConvertProgram
}

typealias IntcodeProgram = String

extension IntcodeProgram {
    var instructions: [Int]? {
        get {
            guard let instructions = try? convert() else {
                return nil
            }
            return instructions
        }
    }
    
    private func convert() throws -> [Int] {
        return try self.split(separator: ",").compactMap({ substring in
            guard let intValue = Int(String(substring)) else {
                throw IntcodeError.couldntConvertProgram
            }
            return intValue
        })
    }
}

class Computer {
    func compute(program: IntcodeProgram) -> String? {
        guard var instructions = program.instructions else {
            return nil
        }

        Processor().process(&instructions)
        return instructions.map({ return String($0) }).joined(separator: ",")
    }
}

class Processor {
    func process(_ instructions: inout [Int]) -> [Int] {
        var index = 0
        while let operation = Opcode(rawValue: instructions[index]), operation != .exit {
            let addressOne = instructions[index + 1]
            let addressTwo = instructions[index + 2]
            let resultAddress = instructions[index + 3]
            
            let elementOne = instructions[addressOne]
            let elementTwo = instructions[addressTwo]
            switch operation {
                case .add:
                    instructions[resultAddress] = elementOne + elementTwo
                    index += 4
                    break
                case .multiply:
                    instructions[resultAddress] = elementOne * elementTwo
                    index += 4
                    break
                default:
                    continue
            }
        }
        
        return instructions
    }
}

/// ------------------------------------------------------------------------
/// Tests

func testResult(input: String, expected: String) -> String {
    let result = Computer().compute(program: input)
    if result == expected {
        return "Pass"
    } else {
        return "Fail"
    }
}

func testResultPartTwo(noun: Int, verb: Int, expected: Int) -> String {
    let input = "1,\(noun),\(verb),3,1,1,2,3,1,3,4,3,1,5,0,3,2,9,1,19,1,19,5,23,1,23,6,27,2,9,27,31,1,5,31,35,1,35,10,39,1,39,10,43,2,43,9,47,1,6,47,51,2,51,6,55,1,5,55,59,2,59,10,63,1,9,63,67,1,9,67,71,2,71,6,75,1,5,75,79,1,5,79,83,1,9,83,87,2,87,10,91,2,10,91,95,1,95,9,99,2,99,9,103,2,10,103,107,2,9,107,111,1,111,5,115,1,115,2,119,1,119,6,0,99,2,0,14,0"
    
    guard let zeroValue = Computer().compute(program: input)?.split(separator: ",").compactMap({ return Int($0) }).first else {
        return "Fail"
    }
    
    guard expected == zeroValue else {
        return "Fail"
    }
    
    return "Pass"
}

/// ------------------------------------------------------------------------
// Part One

// Test 1,0,0,0,99 -> 2,0,0,0,99
testResult(input: "1,0,0,0,99", expected: "2,0,0,0,99")

// Test 2,3,0,3,99 -> 2,3,0,6,99
testResult(input: "2,3,0,3,99", expected: "2,3,0,6,99")

// Test 2,4,4,5,99,0 -> 2,4,4,5,99,9801
testResult(input: "2,4,4,5,99,0", expected: "2,4,4,5,99,9801")

// Test 1,1,1,4,99,5,6,0,99 -> 30,1,1,4,2,5,6,0,99
testResult(input: "1,1,1,4,99,5,6,0,99", expected: "30,1,1,4,2,5,6,0,99")

// Answer
let partOneResult = Computer().compute(program: "1,12,2,3,1,1,2,3,1,3,4,3,1,5,0,3,2,9,1,19,1,19,5,23,1,23,6,27,2,9,27,31,1,5,31,35,1,35,10,39,1,39,10,43,2,43,9,47,1,6,47,51,2,51,6,55,1,5,55,59,2,59,10,63,1,9,63,67,1,9,67,71,2,71,6,75,1,5,75,79,1,5,79,83,1,9,83,87,2,87,10,91,2,10,91,95,1,95,9,99,2,99,9,103,2,10,103,107,2,9,107,111,1,111,5,115,1,115,2,119,1,119,6,0,99,2,0,14,0")
print("Part One Answer is \(partOneResult?.split(separator: ",").first ?? "No Value")")


/// ------------------------------------------------------------------------
// Part Two

let expected = 19690720
outerLoop: for noun in 77...99 {
    for verb in 44...99 {
        if testResultPartTwo(noun: noun, verb: verb, expected: expected) == "Pass" {
            print("Result is noun: \(noun) verb: \(verb)")
            print("Part Two Answer is \(100 * noun + verb)")
            break outerLoop
        }
    }
}
