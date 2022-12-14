private extension String {
    var isNotEmpty: Bool { !isEmpty }
    
    subscript(_ offset: Int) -> Character? {
        guard offset >= 0 && offset < count else { return nil }
        
        let idx = self.index(startIndex, offsetBy: offset)
        
        return self[idx]
    }
}
private extension Character {
    var charCode: Int {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return Int(scalars[scalars.startIndex].value)
    }
}

public enum Hangul {
    fileprivate static func appendGrouping(
        _ grouping: JungJongGrouping,
        to array: inout [String]
    ) {
        switch grouping {
        case .group(let values):
            array.append(contentsOf: values)
        case .single(let value):
            array.append(value)
        }
    }
    
    public static func disassembleGrouped(_ word: String) -> [[String]] {
        let length = word.count
        var result: [[String]] = []
        for i in 0..<length {
            var temp: [String] = []
            guard let code = word[i]?.charCode else { continue }
            
            if isHangul(code) {
                let code = code - HANGUL_OFFSET
                let jong = code % 28
                let jung = (code - jong) / 28 % 21
                let cho = Int(Double(code - jong) / 28 / 21)
                temp.append(CHO[cho]) // Add initial CHO to temp array
                
                appendGrouping(JUNG[jung], to: &temp)
                
                if jong > 0 {
                    appendGrouping(JONG[jong], to: &temp)
                }
            } else if isConsonant(code) {
                if isCho(code) {
                    temp.append(CHO[CHO_HASH[code]!])
                } else {
                    let jong = JONG[JONG_HASH[code]!]
                    appendGrouping(jong, to: &temp)
                }
            } else if isJung(code) {
                let jung = JUNG[JUNG_HASH[code]!]
                appendGrouping(jung, to: &temp)
            } else if let char = word[i] {
                temp.append(String(char))
            }
            
            result.append(temp)
        }
        
        return result
    }
    
    public static func disassemble(_ word: String) -> [String] {
        let grouped = disassembleGrouped(word)
        var result: [String] = []
        for group in grouped {
            result.append(contentsOf: group)
        }
        
        return result
    }
    
    public static func disassembleToString(_ word: String) -> String {
        let dis = disassemble(word)
        return dis.joined()
    }
}

fileprivate func makeHash(_ array: [String]) -> [Int: Int] {
    var hash: [Int: Int] = [0:0]

    for i in 0..<array.count {
        let key = array[i]
        if let first = key.first {
            hash[first.charCode] = i
        }
    }
    
    return hash
}

fileprivate func makeComplexHash(_ array: [[String]]) -> [Int: [Int : Int]] {
    var hash: [Int: [Int : Int]] = [:]
    for i in 0..<array.count {
        guard let code1 = array[i][0].first?.charCode,
              let code2 = array[i][0].first?.charCode else {
            continue
        }
        
        if hash[code1] == nil {
            hash[code1] = [:]
        }
        
        hash[code1]?[code2] = array[i][2].first?.charCode ?? 0
    }
    
    return hash
}

fileprivate extension Hangul {
    static let CHO: [String] = [
        "???", "???", "???", "???", "???",
        "???", "???", "???", "???", "???", "???",
        "???", "???", "???", "???", "???", "???",
        "???", "???"
    ]
    
    enum JungJongGrouping: ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
        init(stringLiteral literal: String) { self = .single(literal) }
        init(arrayLiteral literal: String...) { self = .group(literal) }
        
        case single(String)
        case group([String])
    }
    
    static let JUNG: [JungJongGrouping] = [
        "???", "???", "???", "???", "???",
        "???", "???", "???", "???", ["???", "???"], ["???", "???"],
        ["???", "???"], "???", "???", ["???", "???"], ["???", "???"], ["???", "???"],
        "???", "???", ["???", "???"], "???"
    ]
    
    static let JONG: [JungJongGrouping] = [
        "", "???", "???", ["???", "???"], "???", ["???", "???"], ["???", "???"], "???", "???",
        ["???", "???"], ["???", "???"], ["???", "???"], ["???", "???"], ["???", "???"], ["???", "???"], ["???", "???"], "???",
        "???", ["???", "???"], "???", "???", "???", "???", "???", "???", "???", "???", "???"
    ]
    
    static let HANGUL_OFFSET = 0xAC00
    
    static let CONSONANTS: [String] = [
        "???", "???", "???", "???", "???", "???", "???", "???",
        "???", "???", "???", "???", "???", "???", "???", "???",
        "???", "???", "???", "???", "???", "???", "???", "???",
        "???", "???", "???", "???", "???", "???"
    ]
    
    static let COMPLETE_CHO: [String] = [
        "???", "???", "???", "???", "???",
        "???", "???", "???", "???", "???", "???",
        "???", "???", "???", "???", "???", "???", "???", "???"
    ]
    
    static let COMPLETE_JUNG: [String] = [
        "???", "???", "???", "???", "???",
        "???", "???", "???", "???", "???", "???",
        "???", "???", "???", "???", "???", "???",
        "???", "???", "???", "???"
    ]
    
    static let COMPLETE_JONG: [String] = [
        "", "???", "???", "???", "???", "???", "???", "???", "???",
        "???", "???", "???", "???", "???", "???", "???", "???",
        "???", "???", "???", "???", "???", "???", "???", "???", "???", "???", "???"
    ]
    
    static let COMPLEX_CONSONANTS: [[String]] = [
        ["???", "???", "???"],
        ["???", "???", "???"],
        ["???", "???", "???"],
        ["???", "???", "???"],
        ["???", "???", "???"],
        ["???", "???", "???"],
        ["???", "???", "???"],
        ["???", "???", "???"],
        ["???", "???", "???"],
        ["???", "???", "???"],
        ["???", "???", "???"]
    ]
    
    static let COMPLEX_VOWELS: [[String]] = [
        ["???", "???", "???"],
        ["???", "???", "???"],
        ["???", "???", "???"],
        ["???", "???", "???"],
        ["???", "???", "???"],
        ["???", "???", "???"],
        ["???", "???", "???"]
    ]
    
    static let CONSONANTS_HASH = makeHash(CONSONANTS)
    static let CHO_HASH = makeHash(COMPLETE_CHO)
    static let JUNG_HASH = makeHash(COMPLETE_JUNG)
    static let JONG_HASH = makeHash(COMPLETE_JONG)
    static let COMPLEX_CONSONANTS_HASH = makeComplexHash(COMPLEX_CONSONANTS)
    static let COMPLEX_VOWELS_HASH = makeComplexHash(COMPLEX_VOWELS)
}

public extension Hangul {
    static func isConsonant(_ char: Int) -> Bool {
        return CONSONANTS_HASH[char] != nil
    }
    
    static func isCho(_ char: Int) -> Bool {
        return CHO_HASH[char] != nil
    }
    
    static func isJung(_ char: Int) -> Bool {
        return JUNG_HASH[char] != nil
    }
    
    static func isJong(_ char: Int) -> Bool {
        return JONG_HASH[char] != nil
    }
    
    static func isHangul(_ char: Int) -> Bool {
        return 0xAC00 <= char && char <= 0xd7a3
    }
    
    static func isJungJoinable(a: Int, b: Int) -> Bool {
        if let _ = COMPLEX_VOWELS_HASH[a]?[b] {
            return true // TODO: Return the vowel?
        }
        
        return false
    }
    
    static func isJongJoinable(a: Int, b: Int) -> Bool {
        if let _ = COMPLEX_CONSONANTS_HASH[a]?[b] {
            return true // TODO: Return the vowel?
        }
        
        return false
    }
}
