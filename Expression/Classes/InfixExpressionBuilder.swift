//
//  InfixExpressionBuilder.swift
//  Expression
//
//  Created by Atharva Vaidya on 6/29/19.
//

import Foundation

public class InfixExpressionBuilder {
    private var expression = [Token]() {
        didSet {
            print("Expression: \(expression)")
        }
    }
    private var expressionStack: Stack<Token> = Stack<Token>()
    
    @discardableResult public func addOperator(operatorType: OperatorType) -> InfixExpressionBuilder {
        expression.append(Token(operatorType: operatorType))
        expressionStack.push(Token(operatorType: operatorType))
        return self
    }
    
    @discardableResult public func addOperand(operand: Double) -> InfixExpressionBuilder {
        expression.append(Token(operand: operand))
        expressionStack.push(Token(operand: operand))
        return self
    }
    
    @discardableResult public func addOpenBracket() -> InfixExpressionBuilder {
        expression.append(Token(tokenType: .openBracket))
        expressionStack.push(Token(tokenType: .openBracket))
        return self
    }
    
    @discardableResult public func addCloseBracket() -> InfixExpressionBuilder {
        expression.append(Token(tokenType: .closeBracket))
        expressionStack.push(Token(tokenType: .closeBracket))
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
        case .operand:
            reversePolishNotation.append(token)
            
        case .openBracket:
            tokenStack.push(token)
            
        case .closeBracket:
            while tokenStack.count > 0, let tempToken = tokenStack.pop(), !tempToken.isOpenBracket {
                reversePolishNotation.append(tempToken)
            }
            
        case let .operatorToken(operatorToken):
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
    
    return (reversePolishNotation.map { token in token.description }.joined(separator: " "), reversePolishNotation)
}
