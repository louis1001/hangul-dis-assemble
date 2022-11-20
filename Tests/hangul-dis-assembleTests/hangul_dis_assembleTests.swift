import XCTest
@testable import HangulDisAssemble

final class hangul_dis_assembleTests: XCTestCase {
    func testEmptyDisassemble() throws {
        XCTAssertEqual(Hangul.disassemble(""), [])
    }
    
    func testRegularDisassemble() throws {
        XCTAssertEqual(Hangul.disassemble("가나다"), ["ㄱ","ㅏ","ㄴ","ㅏ","ㄷ","ㅏ"])

        XCTAssertEqual(Hangul.disassemble("ab가c"), ["a","b","ㄱ","ㅏ","c"])

        XCTAssertEqual(Hangul.disassemble("ab@!23X."), ["a","b","@","!","2","3","X","."])
    }
    
    func testDisasembleJoinedJamo() throws {
        XCTAssertEqual(Hangul.disassemble("ㄲ"), ["ㄲ"])
        
        XCTAssertEqual(Hangul.disassemble("ㄳ"), ["ㄱ","ㅅ"])
        XCTAssertEqual(Hangul.disassemble("ㅚ"), ["ㅗ","ㅣ"])
    }
    
    func testDisassembleToString() throws {
        XCTAssertEqual(Hangul.disassembleToString("매드캣MK2"), "ㅁㅐㄷㅡㅋㅐㅅMK2")
    }
    
    func testDisasembleGrouped() throws {
        XCTAssertEqual(Hangul.disassembleGrouped("매드캣MK2"), [["ㅁ", "ㅐ"], ["ㄷ", "ㅡ"], ["ㅋ", "ㅐ", "ㅅ"], ["M"], ["K"], ["2"]])
    }
}
