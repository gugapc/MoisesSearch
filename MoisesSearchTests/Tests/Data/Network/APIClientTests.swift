//
//  APIClientTests.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 28/04/26.
//

import Testing
import Foundation
@testable import MoisesSearch

@MainActor
struct APIClientTests {
    @Test func request_whenSessionFail_returnsError() async throws {
        let session = URLSessionMock()
        session.error = APIError.invalidRequest
        let sut = APIClient(session: session)

        await #expect(throws: APIError.invalidRequest) {
            let _: [TestItem] = try await sut.request(TestAPITarget.listings)
        }
    }

    @Test func request_whenResponseIsNotHTTPURLResponse_returnsError() async throws {
        let session = URLSessionMock()
        let response = URLResponse()
        session.response = response
        let sut = APIClient(session: session)

        await #expect(throws: APIError.invalidResponse(-1)) {
            let _: [TestItem] = try await sut.request(TestAPITarget.listings)
        }
    }

    @Test func request_whenStatusCodeIsFail_returnsError() async throws {
        let session = URLSessionMock()
        let response = HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)
        session.response = response
        let sut = APIClient(session: session)

        await #expect(throws: APIError.invalidResponse(400)) {
            let _: [TestItem] = try await sut.request(TestAPITarget.listings)
        }
    }

    @Test func request_whenSuccess_returnsRightData() async throws {
        let session = URLSessionMock()
        let expected = [TestItem(id: 1, title: "title", author: "author")]
        let data = """
            [{"id": 1, "title": "title", "author": "author"}]
            """.data(using: .utf8)
        session.data = data
        session.response = HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let sut = APIClient(session: session)

        let items: [TestItem] = try await sut.request(TestAPITarget.listings)

        #expect(items == expected)
    }
}

