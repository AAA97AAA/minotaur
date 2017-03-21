import XCTest
import LogicKit
@testable import minotaur

struct Wrapper : Equatable, CustomStringConvertible {
  let term : Term

  var description: String {
      return "\(self.term)"
  }

  static func ==(lhs: Wrapper, rhs: Wrapper) -> Bool {
    return (lhs.term).equals (rhs.term)
  }

}

func resultsOf (goal: Goal, variables: [Variable]) -> [[Variable: Wrapper]] {
    var result = [[Variable: Wrapper]] ()
    for s in solve (goal) {
        let solution  = s.reified ()
        var subresult = [Variable: Wrapper] ()
        for v in variables {
            subresult [v] = Wrapper (term: solution [v])
        }
        if !result.contains (where: { x in x == subresult }) {
            result.append (subresult)
        }
    }
    return result
}

class minotaurTests: XCTestCase {

    func testDoors() {
        let from = Variable (named: "from")
        let to   = Variable (named: "to")
        let goal = doors (from: from, to: to)
        XCTAssertEqual(resultsOf (goal: goal, variables: [from, to]).count, 18, "number of doors is incorrect")
    }

    func testEntrance() {
        let location = Variable (named: "location")
        let goal     = entrance (location: location)
        XCTAssertEqual(resultsOf (goal: goal, variables: [location]).count, 2, "number of entrances is incorrect")
    }

    func testExit() {
        let location = Variable (named: "location")
        let goal     = exit (location: location)
        XCTAssertEqual(resultsOf (goal: goal, variables: [location]).count, 2, "number of exits is incorrect")
    }

    func testMinotaur() {
        let location = Variable (named: "location")
        let goal     = minotaur (location: location)
        XCTAssertEqual(resultsOf (goal: goal, variables: [location]).count, 1, "number of minotaurs is incorrect")
    }

    func testPath() {
        let through = Variable (named: "through")
        let goal    = path (from: room (4,4), to: room (3,2), through: through)
        XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 2, "number of paths is incorrect")
    }

    func testBattery() {
        let through = Variable (named: "through")
        let goal    = path (from: room (4,4), to: room (3,2), through: through) &&
                      battery (through: through, level: toNat (7))
        XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 1, "number of paths is incorrect")
    }

    func testLosing() {
        let through = Variable (named: "through")
        let goal    = winning (through: through, level: toNat (6))
        XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 0, "number of paths is incorrect")
    }

    func testWinning() {
        let through = Variable (named: "through")
        let goal    = winning (through: through, level: toNat (7))
        XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 1, "number of paths is incorrect")
    }

    func testAslam1() {
      // il n'existe pas de solution qui vérifie les conditions en 2 pas
        let through = Variable (named: "through")
        let goal = winning(through: through, level:toNat(2))
        XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 0, "number of paths is incorrect")
    }

    func testAslam2() {
      /* sols
        1 - en partant de (1,4) vers la sortie (4,3)
        2 - (4,4) vers (4,3) (chemin direct)
        3 - (4,4) vers (4,3) (détour)
        4 - (4,4) vers (1,1)

        chemin qui ne fonctionne pas par manque de batterie:
        (4,4) vers (1,1) (détour)
        (1,4) vers (1,1)
    */
        let through = Variable (named: "through")
        let goal = winning(through: through, level:toNat(10))
        XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 4, "number of paths is incorrect")
    }

    func testAslam3() {
      /* tous les sols avec nombre max de
        1 - en partant de (1,4) vers la sortie (4,3) -----------> batterie: 7
        2 - (4,4) vers (4,3) (chemin direct)  -----------> batterie: 8
        3 - (4,4) vers (4,3) (détour)  -----------> batterie: 10
        4 - (4,4) vers (1,1)  -----------> batterie: 11
        5 - (4,4) vers (1,1) (détour) ----> le plus long  -----------> batterie: 13
        6 - (1,4) vers (1,1)  -----------> batterie: 10
    */
        let through = Variable (named: "through")
        let goal = winning(through: through, level:toNat(13))
        XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 6, "number of paths is incorrect")
    }


    static var allTests : [(String, (minotaurTests) -> () throws -> Void)] {
      print("Test:")

        return [

            ("testDoors", testDoors),
            ("testEntrance", testEntrance),
            ("testExit", testExit),
            ("testMinotaur", testMinotaur),
            ("testPath", testPath),
            ("testBattery", testBattery),
             ("testLosing", testLosing),
            ("testWinning", testWinning),
            ("testAslam 1", testAslam1),
            ("testAslam 2: 3 sols des 4 sols", testAslam2),
            ("testAslam 2: 4 sols des 4 sols", testAslam3),
        ]
    }
}
