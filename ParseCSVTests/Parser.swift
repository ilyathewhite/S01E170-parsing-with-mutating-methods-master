//
//  Parser.swift
//  Parser
//
//  Created by Ilya Belenkiy on 9/21/19.
//  Copyright © 2019 Ilya Belenkiy. All rights reserved.
//

public struct Parser<A> {
    let run: (inout Substring.UnicodeScalarView) -> A?
}

extension Parser {
    public func run(_ str: String, from startIndex: Int) -> (A?, String) {
        let strStartIndex = str.index(str.startIndex, offsetBy: startIndex)
        var substr = str.unicodeScalars[strStartIndex...]
        let res = run(&substr)
        return (res, String(substr))
    }

    public func run(_ str: String) -> A? {
        let (value, remaining) = run(str, from: 0)
        guard let res = value, remaining.isEmpty else { return nil }
        return res
    }
}

public extension Parser {
    func map<B>(_ f: @escaping (A) -> B) -> Parser<B> {
        Parser<B> { str in
            self.run(&str).map(f)
        }
    }

    func flatMap<B>(_ f: @escaping (A) -> Parser<B>) -> Parser<B> {
        Parser<B> { str in
            let original = str
            let matchA = self.run(&str)
            let parserB = matchA.map(f)
            guard let matchB = parserB?.run(&str) else {
                str = original
                return nil
            }
            return matchB
        }
    }

    init(wrapped: @escaping () -> Parser<A>) {
        self = Parser { str in
            return wrapped().run(&str)
        }
    }
}

public protocol Parsable: ExpressibleByStringLiteral {
    static var parser: Parser<Self> { get }
}

extension Parsable {
    public init(stringLiteral value: String) {
        self = Self.parser.run(value)! // swiftlint:disable:this force_unwrapping
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self = Self.parser.run(value)! // swiftlint:disable:this force_unwrapping
    }

    public init(unicodeScalarLiteral value: String) {
        self = Self.parser.run(value)! // swiftlint:disable:this force_unwrapping
    }

    public static func parse(_ string: String) -> Self? {
        Self.parser.run(string)
    }
}
