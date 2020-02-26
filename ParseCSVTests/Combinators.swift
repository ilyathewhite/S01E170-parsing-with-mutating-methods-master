//
//  Combinators.swift
//  Parser
//
//  Created by Ilya Belenkiy on 9/22/19.
//  Copyright © 2019 Ilya Belenkiy. All rights reserved.
//

public func zip<A, B>(_ a: Parser<A>, _ b: Parser<B>) -> Parser<(A, B)> {
    return Parser { str in
        let original = str
        guard let matchA = a.run(&str) else { return nil }
        guard let matchB = b.run(&str) else {
            str = original
            return nil
        }
        return (matchA, matchB)
    }
}

public func zip<A, B, C>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>
) -> Parser<(A, B, C)> {
    return zip(a, zip(b, c))
        .map { a, bc in (a, bc.0, bc.1) }
}

public func zip<A, B, C, D>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>,
    _ d: Parser<D>
) -> Parser<(A, B, C, D)> {
    return zip(a, zip(b, c, d))
        .map { a, bcd in (a, bcd.0, bcd.1, bcd.2) }
}

public func zip<A, B, C, D, E>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>,
    _ d: Parser<D>,
    _ e: Parser<E>
) -> Parser<(A, B, C, D, E)> {

    return zip(a, zip(b, c, d, e))
        .map { a, bcde in (a, bcde.0, bcde.1, bcde.2, bcde.3) }
}

public func zip<A, B, C, D, E, F>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>,
    _ d: Parser<D>,
    _ e: Parser<E>,
    _ f: Parser<F>
) -> Parser<(A, B, C, D, E, F)> {
    return zip(a, zip(b, c, d, e, f))
        .map { a, bcdef in (a, bcdef.0, bcdef.1, bcdef.2, bcdef.3, bcdef.4) }
}

public func zip<A, B, C, D, E, F, G>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>,
    _ d: Parser<D>,
    _ e: Parser<E>,
    _ f: Parser<F>,
    _ g: Parser<G>
) -> Parser<(A, B, C, D, E, F, G)> {
    return zip(a, zip(b, c, d, e, f, g))
        .map { a, bcdefg in (a, bcdefg.0, bcdefg.1, bcdefg.2, bcdefg.3, bcdefg.4, bcdefg.5) }
}

public extension Parser {
    static func always(_ a: A) -> Parser {
        return Parser { _ in a }
    }

    static var never: Parser {
        return Parser { _ in nil }
    }

    static func literal(_ str: String, as match: A) -> Parser {
        return Parser<Void>.literal(str).map { _ in match }
    }

    static func firstLiteral(_ args: String..., as match: A) -> Parser {
        firstLiteral(args, as: match)
    }

    static func firstLiteral(_ args: [String], as match: A) -> Parser {
        first(args.map { Parser<Void>.literal($0) }).map { _ in match }
    }

    static func longestLiteral(_ args: String..., as match: A) -> Parser {
        longestLiteral(args, as: match)
    }

    static func longestLiteral(_ args: [String], as match: A) -> Parser {
        longest(args.map { Parser<Void>.literal($0) }).map { _ in match }
    }
}

extension Parser where A == Void {
    public static let noDelimiter = always(())
}

extension Parser {
    public static func zeroOrMore<A>(_ parser: Parser<A>, delimiter: Parser<Void>) -> Parser<[A]> {
        return Parser<[A]> { str in
            var match: [A] = []
            if let value = parser.run(&str) {
                match.append(value)
            }
            else {
                return match
            }

            while !str.isEmpty {
                let remaining = str
                guard let _ = delimiter.run(&str) else { // swiftlint:disable:this unused_optional_binding
                    str = remaining
                    return match
                }
                guard let value = parser.run(&str) else {
                    str = remaining
                    return match
                }
                match.append(value)
            }

            return match
        }
    }

    public static func delimitedZeroOrMore<A>(_ parser: Parser<A>) -> Parser<[A]> {
        let delimiter = zip(Parser<Void>.literal(","), Parser<Void>.emptyspace).map { _ in () }
        return zeroOrMore(parser, delimiter: delimiter)
    }

    public static func first<A>(_ parsers: Parser<A>...) -> Parser<A> {
        first(parsers)
    }

    public static func first<A>(_ parsers: [Parser<A>]) -> Parser<A> {
        return Parser<A> { str in
            for parser in parsers {
                if let match = parser.run(&str) {
                    return match
                }
            }
            return nil
        }
    }

    public static func longest<A>(_ parsers: Parser<A>...) -> Parser<A> {
        longest(parsers)
    }

    public static func longest<A>(_ parsers: [Parser<A>]) -> Parser<A> {
        return Parser<A> { str in
            let original = str
            var parsed: [(match: A, str: Substring)] = []
            for parser in parsers {
                guard let match = parser.run(&str) else { continue }
                parsed.append((match, str))
                str = original
            }
            guard let res = parsed.max(by: { $0.str.startIndex < $1.str.startIndex }) else {return nil }
            str = res.str
            return res.match
        }
    }
}
