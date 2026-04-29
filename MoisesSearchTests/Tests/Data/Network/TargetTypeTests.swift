//
//  TargetTypeTests.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 28/04/26.
//

import Foundation
import Testing
@testable import MoisesSearch

struct TargetTypeTests {
    @Test func testAPITarget_listings_usesProtocolDefaultValues() {
        let sut = TestAPITarget.listings

        #expect(sut.path == "/test/listings")
        #expect(sut.baseURL == URL(string: "http://localhost:8080")!)
        #expect(sut.header == ["Content-Type": "application/json"])
        #expect(sut.body == nil)
        #expect(sut.queryItems == nil)
        #expect(sut.method == .get)
    }
}
