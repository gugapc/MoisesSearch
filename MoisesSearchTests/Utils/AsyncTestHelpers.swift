//
//  AsyncTestHelpers.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 03/05/26.
//

import Foundation

public func waitUntil(maxTries: Int = 400, condition: () -> Bool) async {
    for _ in 0..<maxTries {
        if condition() { return }
        await Task.yield()
    }
}
