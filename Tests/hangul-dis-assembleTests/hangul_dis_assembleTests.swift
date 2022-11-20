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
}
