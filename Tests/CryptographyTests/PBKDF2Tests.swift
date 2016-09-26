import XCTest
import Cryptography

class PBKDF2Tests: XCTestCase {
    static var allTests = [
        ("testValidation", testValidation),
        ("testSHA1", testSHA1),
        ("testMD5", testMD5),
        ("testPerformance", testPerformance),
    ]
    
    func testValidation() throws {
        let result = try PBKDF2<SHA1>.derive(fromKey: [UInt8]("vapor".utf8), usingSalt: [UInt8]("V4P012".utf8), iterating: 1000, keyLength: 10)
        
        XCTAssert(try PBKDF2<SHA1>.validate(key: [UInt8]("vapor".utf8), usingSalt: [UInt8]("V4P012".utf8), against: result, iterating: 1000))
    }

    func testSHA1() throws {
        // Source: PHP/produce_tests.php
        let tests: [(key: String, salt: String, expected: String, iterations: Int)] = [
            ("password", "longsalt", "1712d0a135d5fcd98f00bb25407035c41f01086a", 1000),
            ("password2", "othersalt", "7a0363dd39e51c2cf86218038ad55f6fbbff6291", 1000),
            ("somewhatlongpasswordstringthatIwanttotest", "1", "8cba8dd99a165833c8d7e3530641c0ecddc6e48c", 1000),
            ("p", "somewhatlongsaltstringthatIwanttotest", "31593b82b859877ea36dc474503d073e6d56a33d", 1000),
        ]
        
        for test in tests {
            let result = try PBKDF2<SHA1>.derive(fromKey: [UInt8](test.key.utf8), usingSalt: [UInt8](test.salt.utf8), iterating: test.iterations).hexString.lowercased()
            
            XCTAssertEqual(result, test.expected.lowercased())
        }
    }
    
    func testSHA2() {
        let hash = SHA256.hash([UInt8]("The quick brown fox jumps over the lazy dog".utf8)).hexString.lowercased()
        XCTAssertEqual(hash, "730e109bd7a8a32b1cb9d9a09aa2325d2430587ddbc0c38bad911525")
    }

    func testMD5() throws {
        // Source: PHP/produce_tests.php
        let tests: [(key: String, salt: String, expected: String, iterations: Int)] = [
            ("password", "longsalt", "95d6567274c3ed283041d5135c798823", 1000),
            ("password2", "othersalt", "78e4d28875d6f3b92a01dbddc07370f1", 1000),
            ("somewhatlongpasswordstringthatIwanttotest", "1", "c91a23ffd2a352f0f49c6ce64146fc0a", 1000),
            ("p", "somewhatlongsaltstringthatIwanttotest", "4d0297fc7c9afd51038a0235926582bc", 1000),
        ]
        
        for test in tests {
            let result = try PBKDF2<MD5>.derive(fromKey: [UInt8](test.key.utf8), usingSalt: [UInt8](test.salt.utf8), iterating: test.iterations).hexString.lowercased()
            
            XCTAssertEqual(result, test.expected.lowercased())
        }
    }
    
    func testPerformance() {
        // ~0.137 release
        measure {
            _ = try! PBKDF2<SHA1>.derive(fromKey: [UInt8]("p".utf8), usingSalt: [UInt8]("somewhatlongsaltstringthatIwanttotest".utf8), iterating: 10_000)
        }
    }
}
