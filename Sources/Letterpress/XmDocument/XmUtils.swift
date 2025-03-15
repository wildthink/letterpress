//
//  XmUtils.swift
//  CardStock
//
//  Created by Jason Jobe on 2/16/25.
//

import Foundation

//infix operator ~ : ComparisonPrecedence

extension StringProtocol {
    
    func caseInsensitiveEqual(_ other: (any StringProtocol)?) -> Bool {
        if let other {
            caseInsensitiveCompare(other) == .orderedSame
        } else { false }
    }

    func caseInsensitiveEqual(_ other: any StringProtocol) -> Bool {
        caseInsensitiveCompare(other) == .orderedSame
    }
    
//    static func ~(lhs: Self, rhs: Self) -> Bool {
//        lhs.caseInsensitiveCompare(rhs) == .orderedSame
//    }
}

extension Sequence {
    func cast<T>(to type: T.Type) -> [T] {
        compactMap { ($0 as? T) }
    }

    func cast<T, U>(to type: T.Type, transform: (T) -> U?) -> [U] {
        compactMap { ($0 as? T).flatMap(transform) }
    }
}
