
import Foundation

extension String.UnicodeScalarView
{
    subscript (index: Int) -> UnicodeScalar
    {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
    subscript (range: CountableClosedRange<Int>) -> [UnicodeScalar]
    {
        var arr: [UnicodeScalar] = [UnicodeScalar](repeating: UnicodeScalar(0), count: self.count)
        for (index, scalar) in self.enumerated()
        {
            arr[index] = scalar
        }
        return arr
    }
}

extension String
{
    func computeExpression() -> Double?
    {
        return Expression(string: self).expressionResult()
    }
}

extension UnicodeScalar
{
    func isOperator()    -> Bool           { return [43, 45, 42, 47, 94].contains(self.value) }
    func isDigit()       -> Bool           { return (48...57).contains(self.value)        }
    func isParanthesis() -> Bool           { return [40, 41].contains(self.value)         }
    func isDot()         -> Bool           { return self.value == 46 }
}



/*
 Last-in first-out stack (LIFO)
 Push and pop are O(1) operations.
 */
public struct Stack<T>
{
    fileprivate var array = [T]()
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var count: Int {
        return array.count
    }
    
    public mutating func push(_ element: T) {
        array.append(element)
    }
    
    public mutating func pop() -> T? {
        return array.popLast()
    }
    
    public func peek() -> T? {
        return array.last
    }
}

extension Stack: Sequence
{
    public func makeIterator() -> AnyIterator<T>
    {
        var curr = self
        return AnyIterator {
            _ -> T? in
            return curr.pop()
        }
    }
}

//Credits to Ali Hafizji on GitHub.
//https://github.com/raywenderlich/swift-algorithm-club/tree/master/Shunting%20Yard
internal enum OperatorAssociativity {
    case LeftAssociative
    case RightAssociative
}

public enum OperatorType: String
{
    case Add = "+"
    case Subtract = "-"
    case Divide = "/"
    case Multiply = "*"
    case Percent = "%"
    case Exponent = "^"
    
    public var description: String {
        switch self {
        case .Add:
            return "+"
        case .Subtract:
            return "-"
        case .Divide:
            return "/"
        case .Multiply:
            return "*"
        case .Percent:
            return "%"
        case .Exponent:
            return "^"
        }
    }
}

public enum TokenType: CustomStringConvertible {
    case OpenBracket
    case CloseBracket
    case Operator(OperatorToken)
    case Operand(Double)
    
    public var description: String {
        switch self {
        case .OpenBracket:
            return "("
        case .CloseBracket:
            return ")"
        case .Operator(let operatorToken):
            return operatorToken.description
        case .Operand(let value):
            return "\(value)"
        }
    }
}

public struct OperatorToken: CustomStringConvertible {
    let operatorType: OperatorType
    
    init(operatorType: OperatorType) {
        self.operatorType = operatorType
    }
    
    var precedence: Int {
        switch operatorType {
        case .Add, .Subtract:
            return 0
        case .Divide, .Multiply, .Percent:
            return 5
        case .Exponent:
            return 10
        }
    }
    
    var associativity: OperatorAssociativity {
        switch operatorType {
        case .Add, .Subtract, .Divide, .Multiply, .Percent:
            return .LeftAssociative
        case .Exponent:
            return .RightAssociative
        }
    }
    
    public var description: String {
        return operatorType.description
    }
}

func <= (left: OperatorToken, right: OperatorToken) -> Bool {
    return left.precedence <= right.precedence
}

func < (left: OperatorToken, right: OperatorToken) -> Bool {
    return left.precedence < right.precedence
}

public struct Token: CustomStringConvertible {
    let tokenType: TokenType
    
    init(tokenType: TokenType) {
        self.tokenType = tokenType
    }
    
    init(operand: Double) {
        tokenType = .Operand(operand)
    }
    
    init(operatorType: OperatorType) {
        tokenType = .Operator(OperatorToken(operatorType: operatorType))
    }
    
    var isOpenBracket: Bool {
        switch tokenType {
        case .OpenBracket:
            return true
        default:
            return false
        }
    }
    
    var isOperator: Bool {
        switch tokenType {
        case .Operator(_):
            return true
        default:
            return false
        }
    }
    
    var isOperand: Bool {
        switch tokenType {
        case .Operand(_):
            return true
        default:
            return false
        }
    }
    
    var operatorToken: OperatorToken? {
        switch tokenType {
        case .Operator(let operatorToken):
            return operatorToken
        default:
            return nil
        }
    }
    
    public var description: String {
        return tokenType.description
    }
}

public class InfixExpressionBuilder
{
    private var expression = [Token]()
    
    public func addOperator(operatorType: OperatorType) -> InfixExpressionBuilder {
        expression.append(Token(operatorType: operatorType))
        return self
    }
    
    public func addOperand(operand: Double) -> InfixExpressionBuilder {
        expression.append(Token(operand: operand))
        return self
    }
    
    public func addOpenBracket() -> InfixExpressionBuilder {
        expression.append(Token(tokenType: .OpenBracket))
        return self
    }
    
    public func addCloseBracket() -> InfixExpressionBuilder {
        expression.append(Token(tokenType: .CloseBracket))
        return self
    }
    
    public func build() -> [Token] {
        // Maybe do some validation here
        return expression
    }
}

// This returns the result of the shunting yard algorithm
public func reversePolishNotation(expression: [Token]) -> (String, [Token]) {
    
    var tokenStack = Stack<Token>()
    var reversePolishNotation = [Token]()
    
    for token in expression {
        switch token.tokenType {
        case .Operand(_):
            reversePolishNotation.append(token)
            
        case .OpenBracket:
            tokenStack.push(token)
            
        case .CloseBracket:
            while tokenStack.count > 0, let tempToken = tokenStack.pop(), !tempToken.isOpenBracket {
                reversePolishNotation.append(tempToken)
            }
            
        case .Operator(let operatorToken):
            for tempToken in tokenStack.makeIterator() {
                if !tempToken.isOperator {
                    break
                }
                
                if let tempOperatorToken = tempToken.operatorToken {
                    if operatorToken.associativity == .LeftAssociative && operatorToken <= tempOperatorToken
                        || operatorToken.associativity == .RightAssociative && operatorToken < tempOperatorToken {
                        reversePolishNotation.append(tokenStack.pop()!)
                    } else {
                        break
                    }
                }
            }
            tokenStack.push(token)
        }
    }
    
    while tokenStack.count > 0 {
        reversePolishNotation.append(tokenStack.pop()!)
    }
    
    
    return (reversePolishNotation.map({token in token.description}).joined(separator: " "), reversePolishNotation)
}



open class Expression
{
    private var  expression: String
    private var  result    : Double
    
    init(string: String)
    {
        self.expression = string.replacingOccurrences(of: "﹢", with: "+").replacingOccurrences(of: "﹣", with: "-").replacingOccurrences(of: "×", with: "*").replacingOccurrences(of: "÷", with: "/").replacingOccurrences(of: " ", with: "")
        self.result     = 0
    }
    
    //Follows the PEMDAS rule.
    func expressionResult() -> Double?
    {
        if isValidExpression()
        {
            print("Expression: \(expression) is valid")
            return computeExpression()
        }
        else
        {
            print("Expression: \(expression) isn't valid")
            return nil
        }
    }
    
    private func parseIntoNumbersAndOperators(from string: String) -> ([Double], [OperatorType])
    {
        var numbers: [Double] = []
        var operators: [OperatorType] = []
        var number: String = ""
        
        for (index, character) in string.unicodeScalars.enumerated()
        {
            if character.isDigit() || character.isDot()
            {
                number.append("\(character)")
            }
                
            else if character.isOperator()
            {
                if index != 0 && !string.unicodeScalars[index - 1].isOperator()
                {
                    numbers.append(Double(number)!)
                    number = ""
                    operators.append(OperatorType(rawValue: "\(character)")!)
                }
                else
                {
                    number = ""
                }
            }
        }
        
        numbers.append(Double(number)!)
        
        print("Numbers: \(numbers), Operators: \(operators)")
        
        return (numbers, operators)
    }
    
    //private func parseNumber(from string: String
    
    func resultFrom(operating operater: OperatorType, on numbers: [Double]) -> Double
    {
        let n1 = numbers[0], n2 = numbers[1]
        print("Operating on \(numbers) with \(operater)")
        switch operater
        {
        case .Add:      return n1 + n2
        case .Subtract: return n2 - n1
        case .Multiply: return n1 * n2
        case .Divide:   return n2 / n1
        case .Exponent: return pow(n2, n1)
        case .Percent:  return n2.truncatingRemainder(dividingBy: n1)
        }
    }
    
    func resultFrom(operating operater: String, on numbers: [Double]) -> Double
    {
        let n1 = numbers[0], n2 = numbers[1]
        print("Operating on \(numbers) with \(operater)")
        switch operater
        {
        case OperatorType.Add.rawValue:      return n1 + n2
        case OperatorType.Subtract.rawValue: return n2 - n1
        case OperatorType.Multiply.rawValue: return n1 * n2
        case OperatorType.Divide.rawValue:   return n2 / n1
        case OperatorType.Exponent.rawValue: return pow(n2, n1)
        case OperatorType.Percent.rawValue:  return n2.truncatingRemainder(dividingBy: n1)
        default: fatalError("\(operater.unicodeScalars[0].value)")
        }
    }
    
    
    private func computeExpression() -> Double
    {
        let expressionBuilder = InfixExpressionBuilder()
        
        let (numbers, _) = parseIntoNumbersAndOperators(from: expression)
        var numbersIndex = 0
        for (index, char) in expression.unicodeScalars.enumerated()
        {
            if char.isOperator()
            {
                _ = expressionBuilder.addOperand(operand: numbers[numbersIndex])
                numbersIndex += 1
                _ = expressionBuilder.addOperator(operatorType: OperatorType(rawValue: "\(char)")!)
            }
            if char.isParanthesis()     { _ = char == "(" ? expressionBuilder.addOpenBracket() : expressionBuilder.addCloseBracket() }
            if index == expression.unicodeScalars.count - 1 { _ = expressionBuilder.addOperand(operand: numbers[numbersIndex]) }
        }
        print("Expression: \(expressionBuilder.build())")
        let (RPN, tokens) = reversePolishNotation(expression: expressionBuilder.build())
        print("RPN: \(RPN)")
        var stack = Stack<Token>()
        
        var tokenCounter = 0
        for token in tokens
        {
            if token.isOperand { stack.push(token) }
            else
            {
                let numbers = [Double(stack.pop()!.description)!, Double(stack.pop()!.description)!]
                stack.push(Token(operand: resultFrom(operating: token.tokenType.description, on: numbers)))
            }
            
            tokenCounter += 1
        }
        
        return Double((stack.pop()?.description)!)!
    }
    
    
    func isValidExpression() -> Bool
    {
        //If you're on first or last then check if not operator
        if !(expression.unicodeScalars.last!.isDigit()) && !(expression.unicodeScalars.last!.isParanthesis()) { return false }
        //If number of left brackets doesn't equal number of right brackets return false
        if expression.components(separatedBy: "(").count != expression.components(separatedBy: ")").count     { return false }
        if expression.unicodeScalars.map({$0.isDigit()}) == [Bool](repeating: false, count: expression.unicodeScalars.count) { return false }
        
        for (index, character) in expression.unicodeScalars.enumerated()
        {
            //Logic: If current char is operator then check if next is an operator and the one after that is not an operator.
            //Edge case: if
            if character.isOperator() && index + 2 < expression.unicodeScalars.count && expression.unicodeScalars[index + 1...index + 2].map( { $0.isOperator() }) == [true, true]
            {
                return false
            }
        }
        
        return true
    }
    
}
