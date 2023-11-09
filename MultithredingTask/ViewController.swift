//
//  ViewController.swift
//  MultithredingTask
//
//  Created by Keto Nioradze on 10.11.23.
//

import UIKit

enum SomeError: Error {
    case winnerNotFound
}

func factorial(of number: Int) -> Int {
    if number == 0 {
        return 1
    } else {
        return number * factorial(of: number - 1)
    }
}

func generateRandomNumber() -> Int {
    return Int.random(in: 20...50)
}

func calculateFactorialAndPrintWinner() async {
    let number1 = generateRandomNumber()
    let number2 = generateRandomNumber()

    print("Generated Numbers: \(number1) and \(number2)")

    let task1 = Task {
        let result1 = factorial(of: number1)
        print("Factorial of number 1 (\(number1)): \(result1)")
        return ("Task 1", result1)
    }

    let task2 = Task {
        let result2 = factorial(of: number2)
        print("Factorial of number 2 (\(number2)): \(result2)")
        return ("Task 2", result2)
    }

    do {
        let winner = try await withThrowingTaskGroup(of: (String, Int).self) { group -> String in
            group.addTask { await task1.value }
            group.addTask { await task2.value }

            var results: [(String, Int)] = []
            for try await (taskName, result) in group {
                results.append((taskName, result))
            }

            if let maxResult = results.max(by: { $0.1 < $1.1 }) {
                return maxResult.0
            } else {
                throw SomeError.winnerNotFound
            }
        }

        print("Winner thread: \(winner)")
    } catch {
        print("Error: \(error)")
    }
    
    func main() {
        Task {
            await calculateFactorialAndPrintWinner()
        }
    }

    main()
}



