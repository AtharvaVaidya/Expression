//
//  OperatorType.swift
//  Expression
//
//  Created by Atharva Vaidya on 6/29/19.
//

import Foundation

public enum OperatorType: String {
    case add = "+"
    case subtract = "-"
    case divide = "/"
    case multiply = "*"
    case percent = "%"
    case exponent = "^"
    
    public var description: String {
        switch self {
        case .add:
            return "+"
        case .subtract:
            return "-"
        case .divide:
            return "/"
        case .multiply:
            return "*"
        case .percent:
            return "%"
        case .exponent:
            return "^"
        }
    }
}
