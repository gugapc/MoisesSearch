//
//  APIErrorTests.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 28/04/26.
//

import Foundation
import Testing
@testable import MoisesSearch

struct APIErrorTests {
    @Test func equatable_whenSimpleCasesOrStatusCode_comparesCaseAndCode() {
        #expect(APIError.invalidURL == APIError.invalidURL)
        #expect(APIError.invalidRequest == APIError.invalidRequest)
        #expect(APIError.invalidResponse(404) == APIError.invalidResponse(404))

        #expect(APIError.invalidURL != APIError.invalidRequest)
        #expect(APIError.invalidResponse(400) != APIError.invalidResponse(401))
        #expect(APIError.invalidURL != APIError.invalidResponse(0))
    }

    @Test func equatable_whenDecodeError_comparesNSErrorDomainAndCode() {
        let sameIdentityA = NSError(domain: "test.domain", code: 42, userInfo: [NSLocalizedDescriptionKey: "first message"])
        let sameIdentityB = NSError(domain: "test.domain", code: 42, userInfo: [NSLocalizedDescriptionKey: "other message"])
        #expect(APIError.decodeError(sameIdentityA) == APIError.decodeError(sameIdentityB))

        let otherDomain = NSError(domain: "other.domain", code: 42, userInfo: [:])
        #expect(APIError.decodeError(sameIdentityA) != APIError.decodeError(otherDomain))

        let otherCode = NSError(domain: "test.domain", code: 99, userInfo: [:])
        #expect(APIError.decodeError(sameIdentityA) != APIError.decodeError(otherCode))
    }
}
