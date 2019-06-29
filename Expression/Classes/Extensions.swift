//
//  Extensions.swift
//  Expression
//
//  Created by Atharva Vaidya on 6/29/19.
//

import Foundation

extension String.UnicodeScalarView {
    subscript(index: Int) -> UnicodeScalar {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
    
    subscript(_: CountableClosedRange<Int>) -> [UnicodeScalar] {
        var arr: [UnicodeScalar] = [UnicodeScalar](repeating: UnicodeScalar(0), count: count)
        for (index, scalar) in enumerated() {
            arr[index] = scalar
        }
        return arr
    }
}

extension String {
    func computeExpression() -> Double? {
        return Expression(string: self).expressionResult()
    }
}

extension UnicodeScalar {
    func isOperator() -> Bool { return [43, 45, 42, 47, 94].contains(value) }
    func isDigit() -> Bool { return (48 ... 57).contains(value) }
    func isParanthesis() -> Bool { return [40, 41].contains(value) }
    func isDot() -> Bool { return value == 46 }
}

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
