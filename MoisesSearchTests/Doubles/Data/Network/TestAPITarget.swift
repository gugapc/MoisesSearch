//
//  TestAPITarget.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 28/04/26.
//

import Foundation
@testable import MoisesSearch

enum TestAPITarget: TargetType {
    case listings

    var path: String { "/test/listings" }
}

