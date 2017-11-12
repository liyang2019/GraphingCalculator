//
//  CalculatorBrian.swift
//  Calculator
//
//  Created by Li Yang on 6/25/17.
//  Copyright © 2017 Rice University. All rights reserved.
//

import Foundation

var variables: Dictionary<String, Double>?

struct CalculatorBrain {
    
    mutating func addUnaryOperation(named symbol: String, _ operation: @escaping (Double) -> Double) { // @escaping: the function is stored somewhere else
        operations[symbol] = Operation.unaryOperation(operation)
    }
    
    // to store the operation and operand sequence
    var sequence = [String]()
    
    // to be deprecated
    var result: Double?
    var resultIsPending = false
    var description = ""
    
    private enum Operation {
        case constant(Double)
        case random
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi), // Double.pi,
        "e" : Operation.constant(M_E), // M_E,
        
        "R" : Operation.random,
        
        "√" : Operation.unaryOperation(sqrt), // square root
        "cos" : Operation.unaryOperation(cos), // cos
        "sin" : Operation.unaryOperation(sin), // sin
        "tan" : Operation.unaryOperation(tan), // tan
        "ln" : Operation.unaryOperation(log), // ln
        "exp" : Operation.unaryOperation(exp), // e^x
        "1/x" : Operation.unaryOperation({ 1.0 / $0 }), // factorial
        "±" : Operation.unaryOperation({ -$0 }),
        
        "x^y" : Operation.binaryOperation(pow), // x to the power of y
        "%" : Operation.binaryOperation({ Double(Int($0) % Int($1)) }),
        "x" : Operation.binaryOperation({ $0 * $1 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }),
        "+" : Operation.binaryOperation({ $0 + $1 }),
        "-" : Operation.binaryOperation({ $0 - $1 }),
        "=" : Operation.equals,
        ]
    
    mutating func performOperation(_ symbol: String) {
        sequence.append(symbol)
        (result, resultIsPending, description) = evaluate(using: variables)
    }
    
    mutating func setOperand(_ operand: Double) {
        if sequence.last != "=" {
            sequence.append(formatter.string(from: NSNumber(value: operand))!)
        }
    }
    
    mutating func setOperand(variable named: String) {
        if sequence.last != "=" {
            sequence.append(named)
        }
    }
    
    private let formatter = NumberFormatter()
    init() {
        formatter.maximumFractionDigits = 6
        formatter.minimumIntegerDigits = 1
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil)
        -> (result: Double?, isPending: Bool, description: String) {
            var (result, isPending, description): (Double?, Bool, String) = (nil, false, "")
            var pendingDescription: String?
            var pendingBinaryOperation: PendingBinaryOperation?
            
            struct PendingBinaryOperation {
                let function: (Double, Double) -> Double
                let firstOperand: Double
                
                func perform(with secondOperand: Double) -> Double {
                    return function(firstOperand, secondOperand)
                }
            }
            
            func performPendingBinaryOperation() {
                if pendingBinaryOperation != nil && result != nil {
                    result = pendingBinaryOperation!.perform(with: result!)
                    pendingBinaryOperation = nil
                }
            }
            
            for symbol in sequence {
                print(symbol, terminator: "")
                if let operand = Double(symbol) {
                    result = operand
                    pendingDescription = formatter.string(from: NSNumber(value: operand))
                } else if let operation = operations[symbol] {
                    switch operation {
                    case .constant(let value):
                        if sequence.last != "=" {
                            result = value
                            pendingDescription = symbol
                        }
                    case .random:
                        if sequence.last != "=" {
                            result = Double(arc4random()) / Double(UInt32.max)
                            pendingDescription = symbol
                        }
                    case .unaryOperation(let function):
                        if result != nil {
                            result = function(result!)
                            if isPending {
                                pendingDescription = symbol + "(" + pendingDescription! + ")"
                            } else {
                                if description != "" {
                                    pendingDescription = symbol + "(" + description + ")"
                                    description = ""
                                } else {
                                    pendingDescription = symbol + "(" + pendingDescription! + ")"
                                }
                            }
                        }
                    case .binaryOperation(let function):
                        performPendingBinaryOperation()
                        pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: result!)
                        if !isPending {
                            if description == "" {
                                description = pendingDescription! + symbol
                            } else {
                                description += symbol
                            }
                            isPending = true
                        } else {
                            description += pendingDescription! + symbol
                            pendingDescription = nil
                        }
                    case .equals:
                        performPendingBinaryOperation()
                        isPending = false
                        if pendingDescription != nil {
                            description += pendingDescription!
                            pendingDescription = nil
                        }
                    }
                } else {
                    result = variables == nil ? 0 : variables![symbol]
                    print("(" + String(result!) + ")", terminator: "")
                    pendingDescription = symbol
                }
                
            }
            print(" ")
            return (result, isPending, description)
    }
    
    mutating func clearAll() {
        sequence = []
        variables = nil
        result = nil
        resultIsPending = false
        description = ""
    }
    
}

