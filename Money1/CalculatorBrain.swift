//
//  CalculatorBrain.swift
//  Money1
//
//  Created by ruru on 2017/7/28.
//  Copyright © 2017年 ruru. All rights reserved.
//

import Foundation


class CalculatorBrain {
    
    fileprivate var accumulator = 0.0
    fileprivate var history: [String] = []
    fileprivate var lastOperation :LastOperation = .clear
    
    fileprivate let dotdotdot: String = " ..."
    
    fileprivate let operations: Dictionary<String, Operation> = [
        //        "π": Operation.constant(M_PI),
        //        "e": Operation.constant(M_E),
        //        "√": Operation.unaryOperation(sqrt),
        //        "cos": Operation.unaryOperation(cos),
        //        "sin": Operation.unaryOperation(sin),
        //        "tan": Operation.unaryOperation(tan),
        //        "log10": Operation.unaryOperation(log10),
        //        "×": Operation.binaryOperation({ $0 * $1 }),
        "−": Operation.binaryOperation({ $0 - $1 }),
        //        "÷": Operation.binaryOperation({ $0 / $1 }),
        "+": Operation.binaryOperation({ $0 + $1 }),
        "=": Operation.equals,
        "C": Operation.clear,
        "✚": Operation.clear
    ]
    
    fileprivate enum Operation {
        //        case constant(Double)
        //        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
        case clear
    }
    
    fileprivate enum LastOperation {
        case digit
        //        case constant
        //        case unaryOperation
        case binaryOperation
        case equals
        case clear
    }
    
    func setOperand(_ operand: Double) {
        //        if lastOperation == .unaryOperation {
        //            history.removeAll()
        //        }
        
        accumulator = operand
        history.append(String(operand))
        lastOperation = .digit
    }
    
    func performOperand(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
                //            case .constant(let value):
                //                history.append(symbol)
                //                accumulator = value
                //                lastOperation = .constant
                //            case .unaryOperation(let function):
                //                wrapWithParens(symbol)
                //                accumulator = function(accumulator)
            //                lastOperation = .unaryOperation
            case .binaryOperation(let function):
                if lastOperation == .equals {
                    history.removeLast()
                }
                history.append(symbol)
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                lastOperation = .binaryOperation
            case .equals:
                if lastOperation == .binaryOperation {
                    history.append(String(accumulator))
                }
                history.append(symbol)
                executePendingBinaryOperation()
                lastOperation = .equals
            case .clear:
                clear()
                lastOperation = .clear
            }
        }
    }
    
    var result: Double {
        get {
            return accumulator;
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    var description: String {
        get {
            if pending != nil {
                return history.joined(separator: " ") + dotdotdot
            }
            
            return history.joined(separator: " ")
        }
    }
    
    fileprivate func wrapWithParens(_ symbol: String) {
        if lastOperation == .equals {
            history.insert(")", at: history.count - 1)
            history.insert(symbol, at: 0)
            history.insert("(", at: 1)
        } else {
            history.insert(symbol, at: history.count - 1)
            history.insert("(", at: history.count - 1)
            history.insert(")", at: history.count)
        }
    }
    
    fileprivate func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    func clear() {
        accumulator = 0
        pending = nil
        history.removeAll()
        lastOperation = .clear
    }
    
    fileprivate var pending: PendingBinaryOperationInfo?
    
    fileprivate struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
}

