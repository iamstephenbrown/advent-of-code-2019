extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Int {
    var double: Double {
        get {
            return Double(self)
        }
    }
}

enum Direction: String {
    case right = "R"
    case up = "U"
    case left = "L"
    case down = "D"
}

enum MovementError: Error {
    case couldntBuildMovement
}

struct Point {
    let x: Int
    let y: Int
    
    func next(withMovement movement: Movement) -> Point {
        switch(movement.direction) {
            case .left:
                return Point(x: self.x - movement.distance, y: self.y)
            case .down:
                return Point(x: self.x, y: self.y - movement.distance)
            case .right:
                return Point(x: self.x + movement.distance, y: self.y)
            case .up:
                return Point(x: self.x, y: self.y + movement.distance)
        }
    }
}

struct Movement {
    let direction: Direction
    let distance: Int
    
    static func build(_ code: String) throws -> Movement {
        let directionString = String(code.prefix(1))
        let distanceString = String(code.suffix(code.count - 1))
        
        guard
            let direction = Direction(rawValue: directionString),
            let distance = Int(distanceString)
        else {
            throw MovementError.couldntBuildMovement
        }
        
        return Movement(direction: direction, distance: distance)
    }
}

enum GridError: Error {
    case unableToBuildMovements
}

class Grid {
    
    private func buildPoints(route: [String], fromCentralPoint centralPoint: Point) -> [Point]? {
        guard let movements = try? buildMovements(route: route) else {
            return nil
        }
        
        return buildPoints(movements: movements, from: centralPoint)
    }
    
    func minimumIntersectionDistanceTravelled(routeOne: [String], routeTwo: [String]) -> Int? {
        let centralPoint = Point(x: 0, y: 0)
        
        // get the points that each wire travels through
        guard
            let routeOnePoints = buildPoints(route: routeOne, fromCentralPoint: centralPoint),
            let routeTwoPoints = buildPoints(route: routeTwo, fromCentralPoint: centralPoint)
        else {
            return nil
        }
        
        // get the intersections between points
        let intersections = intersectingPointsBetween(routeOnePoints: routeOnePoints, routeTwoPoints: routeTwoPoints)
        
        // return the min distance travelled to intersection
        let intersectionDistances = calculateIntersectionDistancesTravelled(intersections: intersections, routeOne: routeOnePoints, routeTwo: routeTwoPoints, centralPoint: centralPoint)
        return intersectionDistances.min()
    }
    
    
    func minimumIntersectionDistanceManhattan(routeOne: [String], routeTwo: [String]) -> Int? {
        let centralPoint = Point(x: 0, y: 0)
        
        // get the points that each wire travels through
        guard
            let routeOnePoints = buildPoints(route: routeOne, fromCentralPoint: centralPoint),
            let routeTwoPoints = buildPoints(route: routeTwo, fromCentralPoint: centralPoint)
        else {
            return nil
        }
        
        // get the intersections between points
        let intersections = intersectingPointsBetween(routeOnePoints: routeOnePoints, routeTwoPoints: routeTwoPoints)
        
        // return the min distance between intersections
        let intersectionDistances = calculateIntersectionDistances(intersections: intersections, centralPoint: centralPoint)
        return intersectionDistances.min()
    }
    
    private func intersectingPointsBetween(routeOnePoints: [Point], routeTwoPoints: [Point]) -> [Point] {
        var intersections = [Point]()
        for routeOneIndex in routeOnePoints.indices {
            for routeTwoIndex in routeTwoPoints.indices {
                // check intersections between point A-B and X-Y
                guard
                    let aOne = routeOnePoints[safe: routeOneIndex],
                    let aTwo = routeOnePoints[safe: routeOneIndex.advanced(by: 1)],
                    let bOne = routeTwoPoints[safe: routeTwoIndex],
                    let bTwo = routeTwoPoints[safe: routeTwoIndex.advanced(by: 1)],
                    let intersectingPoint = intersectingPointBetween(aOne: aOne, aTwo: aTwo, bOne: bOne, bTwo: bTwo)
                else {
                    continue
                }
                
                intersections.append(intersectingPoint)
            }
        }
        
        return intersections
    }
    
    // shamelessly stolen from hackingwithswift.com
    private func intersectingPointBetween(aOne start1: Point, aTwo end1: Point, bOne start2: Point, bTwo end2: Point) -> Point? {
        // calculate the differences between the start and end X/Y positions for each of our points
        let delta1x = end1.x.double - start1.x.double
        let delta1y = end1.y.double - start1.y.double
        let delta2x = end2.x.double - start2.x.double
        let delta2y = end2.y.double - start2.y.double

        // create a 2D matrix from our vectors and calculate the determinant
        let determinant = delta1x * delta2y - delta2x * delta1y
        if abs(determinant) < 0.0001 {
            // if the determinant is effectively zero then the lines are parallel/colinear
            return nil
        }

        // if the coefficients both lie between 0 and 1 then we have an intersection
        let ab = ((start1.y.double - start2.y.double) * delta2x - (start1.x.double - start2.x.double) * delta2y) / determinant

        if ab > 0 && ab < 1 {
            let cd = ((start1.y.double - start2.y.double) * delta1x - (start1.x.double - start2.x.double) * delta1y) / determinant

            if cd > 0 && cd < 1 {
                // lines cross – figure out exactly where and return it
                let intersectX = start1.x.double + ab * delta1x
                let intersectY = start1.y.double + ab * delta1y
                return Point(x: Int(intersectX), y: Int(intersectY))
            }
        }

        // lines don't cross
        return nil
    }
    
    // Manhattan
    private func calculateIntersectionDistances(intersections: [Point], centralPoint: Point) -> [Int] {
        var distances = [Int]()
        for intersection in intersections {
            let xDistance = abs(intersection.x - centralPoint.x)
            let yDistance = abs(intersection.y - centralPoint.y)
            distances.append(xDistance + yDistance)
        }
        return distances
    }
    
    // Distance Travelled
    private func calculateIntersectionDistancesTravelled(intersections: [Point], routeOne: [Point], routeTwo: [Point], centralPoint: Point) -> [Int] {
        var distances = [Int]()
        for intersection in intersections {
            if
                let routeOneDistance = distanceToPoint(intersection, alongRoute: routeOne, fromCentralPoint: centralPoint),
                let routeTwoDistance = distanceToPoint(intersection, alongRoute: routeTwo, fromCentralPoint: centralPoint)
            {
                let steps = routeOneDistance + routeTwoDistance
                distances.append(steps)
            }
        }
        return distances
    }
    
    
    private func distanceToPoint(_ point: Point, alongRoute routePoints: [Point], fromCentralPoint centralPoint: Point) -> Int? {
        var steps = 0
        var currentPoint = centralPoint
        for routePoint in routePoints {
            // is the point between the last point and the next one?
            if let distanceToPoint = distanceToPoint(point, between: currentPoint, and: routePoint) {
                return steps + distanceToPoint
            }
            
            steps += distanceBetweenPoint(currentPoint, and: routePoint)
            currentPoint = routePoint
        }
        
        // if we never found an intersection, we do not have a distance
        return nil
    }
    
    private func distanceBetweenPoint(_ pointA: Point, and pointB: Point) -> Int {
        if pointA.x == pointB.x {
            return abs(pointB.y - pointA.y)
        } else {
            return abs(pointB.x - pointA.x)
        }
    }
    
    private func distanceToPoint(_ point: Point, between pointA: Point, and pointB: Point) -> Int? {
        if pointA.x == pointB.x, point.x == pointA.x {
            // intersects vertically, but is it within the points?
            if pointA.y < point.y {
                return point.y - pointA.y
            } else {
                return pointA.y - point.y
            }
        } else if pointA.y == pointB.y, point.y == pointA.y {
            // horizontal line
            if pointA.x < point.x {
                return point.x - pointA.x
            } else {
                return pointA.x - point.x
            }
        }
        
        return nil
    }
    
    private func buildMovements(route: [String]) throws -> [Movement] {
        return try route.map({ direction in
            return try Movement.build(direction)
        })
    }
    
    /// returns the points at turns
    private func buildPoints(movements: [Movement], from centralPoint: Point) -> [Point] {
        var points = [Point]()
        var currentPoint = centralPoint
        for movement in movements {
            let nextPoint = currentPoint.next(withMovement: movement)
            points.append(nextPoint)
            currentPoint = nextPoint
        }
        
        return points
    }
}

/// -----------------------------
// Part One Tests
func testPartOne(routeOne: [String], routeTwo: [String], expected: Int) -> String {
    let grid = Grid()
    guard let intersectionDistance = grid.minimumIntersectionDistanceManhattan(routeOne: routeOne, routeTwo: routeTwo) else {
        return "Fail"
    }
    
    guard intersectionDistance == expected else {
        return "Fail"
    }
    
    return "Pass"
}

testPartOne(
    routeOne: ["R75", "D30", "R83", "U83", "L12", "D49", "R71", "U7", "L72"],
    routeTwo: ["U62", "R66", "U55", "R34", "D71", "R55", "D58", "R83"],
    expected: 159
)

testPartOne(
    routeOne: ["R98", "U47", "R26", "D63", "R33", "U87", "L62", "D20", "R33", "U53", "R51"],
    routeTwo: ["U98", "R91", "D20", "R16", "D67", "R40", "U7", "R15", "U6", "R7"],
    expected: 135
)


/// Answer
let partOneResult = Grid().minimumIntersectionDistanceManhattan(
    routeOne: ["L1004", "U406", "L974", "D745", "R504", "D705", "R430", "D726", "R839", "D550", "L913", "D584", "R109", "U148", "L866", "U664", "R341", "U449", "L626", "D492", "R716", "U596", "L977", "D987", "L47", "U612", "L478", "U928", "L66", "D752", "R665", "U415", "R543", "U887", "R315", "D866", "R227", "D615", "R478", "U180", "R255", "D316", "L955", "U657", "R752", "U561", "R786", "U7", "R918", "D755", "R506", "U131", "L875", "D849", "R823", "D755", "L604", "U944", "R186", "D326", "L172", "U993", "L259", "D765", "R427", "D193", "R663", "U470", "L294", "D437", "R645", "U10", "L926", "D814", "L536", "D598", "R886", "D290", "L226", "U156", "R754", "D105", "L604", "D136", "L883", "U87", "R839", "D807", "R724", "U184", "L746", "D79", "R474", "U186", "R727", "U9", "L69", "U565", "R459", "D852", "R61", "U370", "L890", "D439", "L431", "U846", "R460", "U358", "R51", "D407", "R55", "U179", "L385", "D652", "R193", "D52", "L569", "U980", "L185", "U813", "R636", "D275", "L585", "U590", "R215", "U947", "R851", "D127", "L249", "U954", "L884", "D235", "R3", "U735", "R994", "D883", "L386", "D506", "L963", "D751", "L989", "U733", "L221", "U890", "L711", "D32", "L74", "U437", "L700", "D977", "L49", "U478", "R438", "D27", "R945", "D670", "L230", "U863", "L616", "U461", "R267", "D25", "L646", "D681", "R426", "D918", "L791", "U712", "L730", "U715", "L67", "U359", "R915", "D524", "L722", "U374", "L582", "U529", "L802", "D865", "L596", "D5", "R323", "U235", "R405", "D62", "R304", "U996", "L939", "U420", "L62", "D299", "R802", "D803", "L376", "U430", "L810", "D334", "L67", "U395", "L818", "U953", "L817", "D411", "L225", "U383", "R247", "D234", "L430", "U315", "L418", "U254", "L964", "D372", "R979", "D301", "R577", "U440", "R924", "D220", "L121", "D785", "L609", "U20", "R861", "U288", "R388", "D410", "L278", "D748", "L800", "U755", "L919", "D985", "L785", "U676", "R916", "D528", "L507", "D469", "L582", "D8", "L900", "U512", "L764", "D124", "L10", "U567", "L379", "D231", "R841", "D244", "R479", "U145", "L769", "D845", "R651", "U712", "L920", "U791", "R95", "D958", "L608", "D755", "R967", "U855", "R563", "D921", "L37", "U699", "L944", "U718", "R959", "D195", "L922", "U726", "R378", "U258", "R340", "D62", "L555", "D135", "L690", "U269", "L273", "D851", "L60", "D851", "R1", "D315", "R117", "D855", "L275", "D288", "R25", "U503", "R569", "D596", "L823", "U687", "L450"],
    routeTwo: ["R990", "U475", "L435", "D978", "L801", "D835", "L377", "D836", "L157", "D84", "R329", "D342", "R931", "D522", "L724", "U891", "L508", "U274", "L146", "U844", "R686", "D441", "R192", "U992", "L781", "D119", "R436", "D286", "R787", "D85", "L801", "U417", "R619", "D710", "R42", "U261", "R296", "U697", "L354", "D843", "R613", "U880", "R789", "D134", "R636", "D738", "L939", "D459", "L338", "D905", "R811", "D950", "L44", "U992", "R845", "U771", "L563", "D76", "L69", "U839", "L57", "D311", "L615", "D931", "L437", "D201", "L879", "D1", "R978", "U415", "R548", "D398", "L560", "D112", "L894", "D668", "L708", "D104", "R622", "D768", "R901", "D746", "L793", "D26", "R357", "U216", "L216", "D33", "L653", "U782", "R989", "U678", "L7", "D649", "R860", "D281", "L988", "U362", "L525", "U652", "R620", "D376", "L983", "U759", "R828", "D669", "L297", "U207", "R68", "U77", "R255", "U269", "L661", "U310", "L309", "D490", "L55", "U471", "R260", "D912", "R691", "D62", "L63", "D581", "L289", "D366", "L862", "D360", "L485", "U946", "R937", "D470", "L792", "D614", "R936", "D963", "R611", "D151", "R908", "D195", "R615", "U768", "L166", "D314", "R640", "U47", "L161", "U872", "R50", "U694", "L917", "D149", "L92", "U244", "L337", "U479", "R755", "U746", "L196", "D759", "L936", "U61", "L744", "D774", "R53", "U439", "L185", "D504", "R769", "D696", "L285", "D396", "R791", "U21", "L35", "D877", "L9", "U398", "R447", "U101", "R590", "U862", "L351", "D210", "L935", "U938", "R131", "U758", "R99", "U192", "L20", "U142", "L946", "D981", "R998", "U214", "R174", "U710", "L719", "D879", "L411", "U839", "L381", "U924", "L221", "D397", "R380", "U715", "R139", "D367", "R253", "D973", "L9", "U624", "L426", "D885", "R200", "U940", "R214", "D75", "R717", "D2", "R578", "U161", "R421", "U326", "L561", "U311", "L701", "U259", "R836", "D920", "R35", "D432", "R610", "D63", "R664", "D39", "L119", "D47", "L605", "D228", "L364", "D14", "L226", "D365", "R796", "D233", "R476", "U145", "L926", "D907", "R681", "U267", "R844", "U735", "L948", "U344", "L629", "U31", "L383", "U694", "L666", "U158", "R841", "D27", "L150", "D950", "L335", "U275", "L184", "D157", "R504", "D602", "R605", "D185", "L215", "D420", "R700", "U809", "L139", "D937", "L248", "U693", "L56", "U92", "L914", "U743", "R445", "U417", "L504", "U23", "R332", "U865", "R747", "D553", "R595", "U845", "R693", "U915", "R81"]
)

print("Part One Answer: \(partOneResult)")

func testPartTwo(routeOne: [String], routeTwo: [String], expected: Int) -> String {
    let grid = Grid()
    guard let intersectionDistance = grid.minimumIntersectionDistanceTravelled(routeOne: routeOne, routeTwo: routeTwo) else {
        return "Fail"
    }
    
    guard intersectionDistance == expected else {
        return "Fail"
    }
    
    return "Pass"
}

testPartTwo(routeOne: ["R75", "D30", "R83", "U83", "L12", "D49", "R71", "U7", "L72"], routeTwo: ["U62", "R66", "U55", "R34", "D71", "R55", "D58", "R83"], expected: 610)

testPartTwo(routeOne: ["R98", "U47", "R26", "D63", "R33", "U87", "L62", "D20", "R33", "U53", "R51"], routeTwo: ["U98", "R91", "D20", "R16", "D67", "R40", "U7", "R15", "U6", "R7"], expected: 410)

let partTwoResult = Grid().minimumIntersectionDistanceTravelled(
    routeOne: ["L1004", "U406", "L974", "D745", "R504", "D705", "R430", "D726", "R839", "D550", "L913", "D584", "R109", "U148", "L866", "U664", "R341", "U449", "L626", "D492", "R716", "U596", "L977", "D987", "L47", "U612", "L478", "U928", "L66", "D752", "R665", "U415", "R543", "U887", "R315", "D866", "R227", "D615", "R478", "U180", "R255", "D316", "L955", "U657", "R752", "U561", "R786", "U7", "R918", "D755", "R506", "U131", "L875", "D849", "R823", "D755", "L604", "U944", "R186", "D326", "L172", "U993", "L259", "D765", "R427", "D193", "R663", "U470", "L294", "D437", "R645", "U10", "L926", "D814", "L536", "D598", "R886", "D290", "L226", "U156", "R754", "D105", "L604", "D136", "L883", "U87", "R839", "D807", "R724", "U184", "L746", "D79", "R474", "U186", "R727", "U9", "L69", "U565", "R459", "D852", "R61", "U370", "L890", "D439", "L431", "U846", "R460", "U358", "R51", "D407", "R55", "U179", "L385", "D652", "R193", "D52", "L569", "U980", "L185", "U813", "R636", "D275", "L585", "U590", "R215", "U947", "R851", "D127", "L249", "U954", "L884", "D235", "R3", "U735", "R994", "D883", "L386", "D506", "L963", "D751", "L989", "U733", "L221", "U890", "L711", "D32", "L74", "U437", "L700", "D977", "L49", "U478", "R438", "D27", "R945", "D670", "L230", "U863", "L616", "U461", "R267", "D25", "L646", "D681", "R426", "D918", "L791", "U712", "L730", "U715", "L67", "U359", "R915", "D524", "L722", "U374", "L582", "U529", "L802", "D865", "L596", "D5", "R323", "U235", "R405", "D62", "R304", "U996", "L939", "U420", "L62", "D299", "R802", "D803", "L376", "U430", "L810", "D334", "L67", "U395", "L818", "U953", "L817", "D411", "L225", "U383", "R247", "D234", "L430", "U315", "L418", "U254", "L964", "D372", "R979", "D301", "R577", "U440", "R924", "D220", "L121", "D785", "L609", "U20", "R861", "U288", "R388", "D410", "L278", "D748", "L800", "U755", "L919", "D985", "L785", "U676", "R916", "D528", "L507", "D469", "L582", "D8", "L900", "U512", "L764", "D124", "L10", "U567", "L379", "D231", "R841", "D244", "R479", "U145", "L769", "D845", "R651", "U712", "L920", "U791", "R95", "D958", "L608", "D755", "R967", "U855", "R563", "D921", "L37", "U699", "L944", "U718", "R959", "D195", "L922", "U726", "R378", "U258", "R340", "D62", "L555", "D135", "L690", "U269", "L273", "D851", "L60", "D851", "R1", "D315", "R117", "D855", "L275", "D288", "R25", "U503", "R569", "D596", "L823", "U687", "L450"],
    routeTwo: ["R990", "U475", "L435", "D978", "L801", "D835", "L377", "D836", "L157", "D84", "R329", "D342", "R931", "D522", "L724", "U891", "L508", "U274", "L146", "U844", "R686", "D441", "R192", "U992", "L781", "D119", "R436", "D286", "R787", "D85", "L801", "U417", "R619", "D710", "R42", "U261", "R296", "U697", "L354", "D843", "R613", "U880", "R789", "D134", "R636", "D738", "L939", "D459", "L338", "D905", "R811", "D950", "L44", "U992", "R845", "U771", "L563", "D76", "L69", "U839", "L57", "D311", "L615", "D931", "L437", "D201", "L879", "D1", "R978", "U415", "R548", "D398", "L560", "D112", "L894", "D668", "L708", "D104", "R622", "D768", "R901", "D746", "L793", "D26", "R357", "U216", "L216", "D33", "L653", "U782", "R989", "U678", "L7", "D649", "R860", "D281", "L988", "U362", "L525", "U652", "R620", "D376", "L983", "U759", "R828", "D669", "L297", "U207", "R68", "U77", "R255", "U269", "L661", "U310", "L309", "D490", "L55", "U471", "R260", "D912", "R691", "D62", "L63", "D581", "L289", "D366", "L862", "D360", "L485", "U946", "R937", "D470", "L792", "D614", "R936", "D963", "R611", "D151", "R908", "D195", "R615", "U768", "L166", "D314", "R640", "U47", "L161", "U872", "R50", "U694", "L917", "D149", "L92", "U244", "L337", "U479", "R755", "U746", "L196", "D759", "L936", "U61", "L744", "D774", "R53", "U439", "L185", "D504", "R769", "D696", "L285", "D396", "R791", "U21", "L35", "D877", "L9", "U398", "R447", "U101", "R590", "U862", "L351", "D210", "L935", "U938", "R131", "U758", "R99", "U192", "L20", "U142", "L946", "D981", "R998", "U214", "R174", "U710", "L719", "D879", "L411", "U839", "L381", "U924", "L221", "D397", "R380", "U715", "R139", "D367", "R253", "D973", "L9", "U624", "L426", "D885", "R200", "U940", "R214", "D75", "R717", "D2", "R578", "U161", "R421", "U326", "L561", "U311", "L701", "U259", "R836", "D920", "R35", "D432", "R610", "D63", "R664", "D39", "L119", "D47", "L605", "D228", "L364", "D14", "L226", "D365", "R796", "D233", "R476", "U145", "L926", "D907", "R681", "U267", "R844", "U735", "L948", "U344", "L629", "U31", "L383", "U694", "L666", "U158", "R841", "D27", "L150", "D950", "L335", "U275", "L184", "D157", "R504", "D602", "R605", "D185", "L215", "D420", "R700", "U809", "L139", "D937", "L248", "U693", "L56", "U92", "L914", "U743", "R445", "U417", "L504", "U23", "R332", "U865", "R747", "D553", "R595", "U845", "R693", "U915", "R81"]
)

print("Part Two Answer: \(partTwoResult)")
