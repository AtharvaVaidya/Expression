
import Foundation

// Credits to Ali Hafizji on GitHub.
// https://github.com/raywenderlich/swift-algorithm-club/tree/master/Shunting%20Yard
internal enum OperatorAssociativity {
    case LeftAssociative
    case RightAssociative
}

open class Expression {
    private var expression: String
    private var result: Double

    public init(string: String) {
        expression = string
            .replacingOccurrences(of: "﹢", with: "+")
            .replacingOccurrences(of: "﹣", with: "-")
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: " ", with: "")
        result = 0
    }

    // Follows the PEMDAS rule.
    public func expressionResult() -> Double? {
        if isValidExpression() {
            print("Expression: \(expression) is valid")
            return computeExpression()
        } else {
            print("Expression: \(expression) isn't valid")
            return nil
        }
    }
    
    private func parseIntoTokens(from string: String) -> [Token] {
        var stack = [Token]()
        var numberString = ""
        
        for (index, character) in string.unicodeScalars.enumerated() {
            if character.isDigit() || character.isDot() {
                numberString += "\(character)"
            } else if character.isOperator() {
                if let number = Double(numberString) {
                    stack.append(Token(operand: number))
                    numberString = ""
                }
    
                stack.append(Token(operatorType: OperatorType(rawValue: "\(character)")!))
            } else if character.isParanthesis() {
                if let number = Double(numberString) {
                    stack.append(Token(operand: number))
                    numberString = ""
                }
                
                stack.append(Token(tokenType: character == "(" ? .openBracket : .closeBracket))
            }
            
            if index == string.unicodeScalars.count - 1 {
                if let number = Double(numberString) {
                    stack.append(Token(operand: number))
                    numberString = ""
                }
            }
        }
        
        return stack
    }
    
    private func parseIntoNumbersAndOperators(from string: String) -> ([Double], [OperatorType]) {
        var numbers: [Double] = []
        var operators: [OperatorType] = []
        var number: String = ""

        for (index, character) in string.unicodeScalars.enumerated() {
            if character.isDigit() || character.isDot() {
                number.append("\(character)")
            } else if character.isOperator() {
                if index != 0, !string.unicodeScalars[index - 1].isOperator() {
                    numbers.append(Double(number)!)
                    number = ""
                    operators.append(OperatorType(rawValue: "\(character)")!)
                } else {
                    number = ""
                }
            }
        }

        numbers.append(Double(number)!)

        print("Numbers: \(numbers), Operators: \(operators)")

        return (numbers, operators)
    }

    // private func parseNumber(from string: String

    func resultFrom(operating operater: OperatorType, on numbers: [Double]) -> Double {
        let n1 = numbers[0], n2 = numbers[1]
        print("Operating on \(numbers) with \(operater)")
        switch operater {
        case .add: return n1 + n2
        case .subtract: return n2 - n1
        case .multiply: return n1 * n2
        case .divide: return n2 / n1
        case .exponent: return pow(n2, n1)
        case .percent: return n2.truncatingRemainder(dividingBy: n1)
        }
    }

    func resultFrom(operating operater: String, on numbers: [Double]) -> Double {
        let n1 = numbers[0], n2 = numbers[1]
        print("Operating on \(numbers) with \(operater)")
        switch operater {
        case OperatorType.add.rawValue: return n1 + n2
        case OperatorType.subtract.rawValue: return n2 - n1
        case OperatorType.multiply.rawValue: return n1 * n2
        case OperatorType.divide.rawValue: return n2 / n1
        case OperatorType.exponent.rawValue: return pow(n2, n1)
        case OperatorType.percent.rawValue: return n2.truncatingRemainder(dividingBy: n1)
        default: fatalError("\(operater.unicodeScalars[0].value)")
        }
    }

    private func computeExpression() -> Double {
        let expressionBuilder = InfixExpressionBuilder()

        let tokenStack = parseIntoTokens(from: expression)
                
        for token in tokenStack {
            switch token.tokenType {
            case .openBracket:
                expressionBuilder.addOpenBracket()
            case .closeBracket:
                expressionBuilder.addCloseBracket()
            case .operand(let operand):
                expressionBuilder.addOperand(operand: operand)
            case .operatorToken(let operatorToken):
                expressionBuilder.addOperator(operatorType: operatorToken.operatorType)
            }
        }
        
        let (_, tokens) = reversePolishNotation(expression: expressionBuilder.build())
        
        var stack = Stack<Token>()

        var tokenCounter = 0
        
        for token in tokens {
            if token.isOperand { stack.push(token) }
            else {
                guard let number1Description = stack.pop()?.description, let number2Description = stack.pop()?.description, let number1 = Double(number1Description), let number2 = Double(number2Description) else {
                    continue
                }
                let numbers = [number1, number2]
                stack.push(Token(operand: resultFrom(operating: token.tokenType.description, on: numbers)))
            }

            tokenCounter += 1
        }
        
        if let description = stack.pop()?.description, let result = Double(description) {
            return result
        } else {
            return 0
        }
    }

    func isValidExpression() -> Bool {
        // If you're on first or last then check if not operator
        if !(expression.unicodeScalars.last!.isDigit()), !(expression.unicodeScalars.last!.isParanthesis()) { return false }
        // If number of left brackets doesn't equal number of right brackets return false
        if expression.components(separatedBy: "(").count != expression.components(separatedBy: ")").count { return false }
        if expression.unicodeScalars.map({ $0.isDigit() }) == [Bool](repeating: false, count: expression.unicodeScalars.count) { return false }

        for (index, character) in expression.unicodeScalars.enumerated() {
            // Logic: If current char is operator then check if next is an operator and the one after that is not an operator.
            // Edge case: if
            if character.isOperator(), index + 2 < expression.unicodeScalars.count, expression.unicodeScalars[index + 1 ... index + 2].map({ $0.isOperator() }) == [true, true] {
                return false
            }
        }

        return true
    }
}
