//
//  OperatorToken.swift
//  Expression
//
//  Created by Atharva Vaidya on 6/29/19.
//

import Foundation

public struct OperatorToken: CustomStringConvertible {
    let operatorType: OperatorType
    
    init(operatorType: OperatorType) {
        self.operatorType = operatorType
    }
    
    var precedence: Int {
        switch operatorType {
        case .add, .subtract:
            return 0
        case .divide, .multiply, .percent:
            return 5
        case .exponent:
            return 10
        }
    }
    
    var associativity: OperatorAssociativity {
        switch operatorType {
        case .add, .subtract, .divide, .multiply, .percent:
            return .LeftAssociative
        case .exponent:
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
