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
        #expect(sut.baseURL == URL(string: "https://itunes.apple.com")!)
        #expect(sut.header == [:])
        #expect(sut.body == nil)
        #expect(sut.queryItems == nil)
        #expect(sut.method == .get)
    }
}
