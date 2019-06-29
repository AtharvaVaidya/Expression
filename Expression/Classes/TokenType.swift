//
//  TokenType.swift
//  Expression
//
//  Created by Atharva Vaidya on 6/29/19.
//

import Foundation

public enum TokenType: CustomStringConvertible {
    case openBracket
    case closeBracket
    case operatorToken(OperatorToken)
    case operand(Double)
    
    public var description: String {
        switch self {
        case .openBracket:
            return "("
        case .closeBracket:
            return ")"
        case let .operatorToken(operatorToken):
            return operatorToken.description
        case let .operand(value):
            return "\(value)"
        }
    }
}
