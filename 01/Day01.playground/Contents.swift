let moduleMasses: [Double] = [89822, 149236, 106135, 147663, 91417, 59765, 66470, 121156, 148632, 116660, 90316, 111666, 142111, 72595, 139673, 145157, 77572, 83741, 79815, 74693, 139077, 106066, 125817, 127827, 103884, 147289, 81588, 142651, 69916, 147214, 71501, 130067, 60182, 139195, 115502, 127751, 95013, 73411, 125294, 79809, 118110, 122547, 145141, 72231, 138853, 108119, 139960, 128665, 107228, 73416, 54608, 63811, 72363, 130546, 61055, 56786, 127718, 144953, 149284, 137318, 109566, 112866, 148063, 130570, 67536, 84011, 123795, 128098, 51687, 83758, 59867, 103122, 77339, 72126, 71446, 67162, 112342, 120248, 137629, 135736, 139781, 92512, 105922, 85458, 148571, 51173, 135047, 110175, 93722, 82611, 128288, 125225, 104177, 115081, 78470, 96167, 138445, 117778, 100133, 140047]

struct Module {
    let mass: Double
    var fuelToLaunch: Double {
        get {
            return requiredFuel(forMass: mass)
        }
    }
    
    private func requiredFuel(forMass mass: Double) -> Double {
        let fuel = (mass / 3).rounded(.down) - 2
        guard fuel > 0 else {
            return 0
        }
        return fuel + requiredFuel(forMass: fuel)
    }
}

struct SpaceCraft {
    let modules: [Module]
    var fuelToLaunch: Double {
        get {
            return modules.reduce(0, { return $0 + $1.fuelToLaunch })
        }
    }
}

let modules = moduleMasses.map({ return Module(mass: $0) })
let spaceCraft = SpaceCraft(modules: modules)
print(spaceCraft.fuelToLaunch) // 5327664
