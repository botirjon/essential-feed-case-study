//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 01/01/25.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ object: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Instance should have been deallocated, potential memory leak", file: file, line: line)
        }
    }
}
