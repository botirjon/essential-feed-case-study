//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 08/12/24.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ object: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
