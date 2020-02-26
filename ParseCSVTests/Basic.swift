//
//  Basic.swift
//  Parser
//
//  Created by Ilya Belenkiy on 9/22/19.
//  Copyright © 2019 Ilya Belenkiy. All rights reserved.
//

extension UnicodeScalar {
    var isWhitespace: Bool {
        self.properties.isWhitespace
    }

    var decimalDigitValue: Int? {
        let zero = UnicodeScalar("0")
        let res = value - zero.value
        return (res >= 0) && (res <= 9) ? Int(res) : nil
    }
}

extension Substring.UnicodeScalarView {
    func hasPrefix(_ value: String) -> Bool {
        return zip(self, value.unicodeScalars).first(where: { $0.0 != $0.1 }) == nil
    }
}

public extension Parser where A == Unicode.Scalar {
    static let char = Parser { str in
        guard !str.isEmpty else { return nil }
        let match = str.first
        str = str.dropFirst()
        return match
    }
}

public extension Parser where A == String {
    static func characters(until delimiter: Parser<Void>) -> Parser {
        return Parser { str in
            var res = ""
            while !str.isEmpty {
                let remaining = str
                if let _ = delimiter.run(&str) {
                    str = remaining
                    return res
                }
                else {
                    res.unicodeScalars.append(str.removeFirst())
                }
            }
            return res
        }
    }
}

public extension Parser where A == Void {
    static let emptyspace = Parser { str in
        guard let endIndex = str.firstIndex(where: { !$0.isWhitespace }) else {
            str = str[str.endIndex..<str.endIndex]
            return ()
        }

        str = str[endIndex...]
        return ()
    }

    static func literal(_ value: String) -> Parser<Void> {
        return Parser { str in
            guard str.hasPrefix(value) else { return nil }
            str.removeFirst(value.count)
            return ()
        }
    }
}

public extension Parser where A == Int {
    static let nonNegative = Parser { str in
        var match = 0
        var index = str.startIndex
        while (index != str.endIndex), let digit = str[index].decimalDigitValue {
            match = match * 10 + digit
            index = str.index(after: index)
        }
        if index == str.startIndex {
            return nil
        }
        else {
            str = str.suffix(from: index)
            return match
        }
    }
}
