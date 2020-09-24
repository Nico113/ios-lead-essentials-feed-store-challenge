//
//  XCTestCase+MemoryLeakTracking.swift
//  Tests
//
//  Created by Nicolas De Maio on 9/24/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.")
        }
    }
}
