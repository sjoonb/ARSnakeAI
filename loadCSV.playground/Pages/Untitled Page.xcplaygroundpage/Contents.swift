import UIKit

struct Person {
    var firstName: String
    var lastName: String
    var age: Int
    var isRegistered: Bool
}

var people = [Person]()

func convertCSVIntoArray() {

    //locate the file you want to use
    guard let filepath = Bundle.main.path(forResource: "data", ofType: "csv") else {
        return
    }

    //convert that file into one long string
    var data = ""
    do {
        data = try String(contentsOfFile: filepath)
    } catch {
        print(error)
        return
    }

    //now split that string into an array of "rows" of data.  Each row is a string.
    var rows = data.components(separatedBy: "\n")

    //if you have a header row, remove it here
    rows.removeFirst()

    //now loop around each row, and split it into each of its columns
    for row in rows {
        let columns = row.components(separatedBy: ",")

        //check that we have enough columns
        if columns.count == 4 {
            let firstName = columns[0]
            let lastName = columns[1]
            let age = Int(columns[2]) ?? 0
            let isRegistered = columns[3] == "True"

            let person = Person(firstName: firstName, lastName: lastName, age: age, isRegistered: isRegistered)
            people.append(person)
        }
    }
}

convertCSVIntoArray()
//print("works?")
//print(people[0])
