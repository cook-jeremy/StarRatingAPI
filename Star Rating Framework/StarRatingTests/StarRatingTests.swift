//
//  StarRatingTests.swift
//  StarRatingTests
//
//  Created by Jeremy Cook on 12/23/23.
//

import XCTest
@testable import StarRating
import SwiftUI

class StarRatingTests: XCTestCase {

    func testTapLocation() throws {
        let rating = Rating(value: .constant(3))
        
        var tapLocation = rating.location(5, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .star(index: 0, remainder: 5 / 20))
        XCTAssertEqual(tapLocation.value(granularity: 0), 5 / 20)
        
        tapLocation = rating.location(20, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .star(index: 0, remainder: 1))
        XCTAssertEqual(tapLocation.value(granularity: 0), 1)
        
        tapLocation = rating.location(21, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .spacer(index: 0))
        XCTAssertEqual(tapLocation.value(granularity: 0), 1)
        
        tapLocation = rating.location(29, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .spacer(index: 0))
        XCTAssertEqual(tapLocation.value(granularity: 0), 1)
        
        tapLocation = rating.location(30, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .star(index: 1, remainder: 0))
        XCTAssertEqual(tapLocation.value(granularity: 0), 1)
        
        tapLocation = rating.location(35, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .star(index: 1, remainder: 0.25))
        XCTAssertEqual(tapLocation.value(granularity: 0), 1 + 5/20)
        
        tapLocation = rating.location(51, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .spacer(index: 1))
        XCTAssertEqual(tapLocation.value(granularity: 0), 2)
        
        tapLocation = rating.location(60, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .star(index: 2, remainder: 0))
        XCTAssertEqual(tapLocation.value(granularity: 0), 2)
        
        tapLocation = rating.location(120, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .star(index: 4, remainder: 0))
        XCTAssertEqual(tapLocation.value(granularity: 0), 4)
        
        tapLocation = rating.location(140, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .star(index: 4, remainder: 1))
        XCTAssertEqual(tapLocation.value(granularity: 0), 5)
        
        tapLocation = rating.location(200, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .star(index: 4, remainder: 1))
        XCTAssertEqual(tapLocation.value(granularity: 0), 5)
        
        tapLocation = rating.location(-20, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .star(index: 0, remainder: 0))
        XCTAssertEqual(tapLocation.value(granularity: 0), 0)
        
        tapLocation = rating.location(-100, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .star(index: 0, remainder: 0))
        XCTAssertEqual(tapLocation.value(granularity: 0), 0)
        
        tapLocation = rating.location(10, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .star(index: 0, remainder: 0.5))
        XCTAssertEqual(tapLocation.value(granularity: 0.5), 1.0)
        XCTAssertEqual(tapLocation.value(granularity: 0.25), 0.75)
        
        tapLocation = rating.location(5, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .star(index: 0, remainder: 0.25))
        XCTAssertEqual(tapLocation.value(granularity: 0.5), 0.5)
        XCTAssertEqual(tapLocation.value(granularity: 0.25), 0.5)
        
        tapLocation = rating.location(15, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .star(index: 0, remainder: 0.75))
        XCTAssertEqual(tapLocation.value(granularity: 0.5), 1)
        XCTAssertEqual(tapLocation.value(granularity: 0.25), 1)
        
        tapLocation = rating.location(200, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .star(index: 4, remainder: 1))
        XCTAssertEqual(tapLocation.value(granularity: 0.5), 5)
        XCTAssertEqual(tapLocation.value(granularity: 0.25), 5)
        
        tapLocation = rating.location(500, starWidth: 20, spacingWidth: 10)
        XCTAssertEqual(tapLocation, .star(index: 4, remainder: 1))
        XCTAssertEqual(tapLocation.value(granularity: 0.5), 5)
        XCTAssertEqual(tapLocation.value(granularity: 0.25), 5)
    }
}
